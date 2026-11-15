#!/usr/bin/env bash
# Sinh so do vat ly IE Crow's Foot tu LUOC DO THAT (Phase 3/01_schema_ddl.sql).
# Quy trinh: postgres:16-alpine tam thoi (g9_eer_db) -> nap DDL -> truy van catalog
#            -> sinh DOT (python3, chi dung thu vien chuan) -> render Graphviz (docker).
# Dau ra: 4_physical_crows_foot.{dot,svg,png} trong cung thu muc voi script.
# Yeu cau: docker, python3, ket noi internet de pull image lan dau. Chay lai bat ky luc nao.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DDL="$(cd "$HERE/../../../Phase 3" && pwd)/01_schema_ddl.sql"
DB=g9_eer_db; GV=g9_eer_dot
GVIMG="${GRAPHVIZ_IMAGE:-nshine/dot}"
DPI="${DPI:-80}"
TMP="$(mktemp -d)"
cleanup() { docker rm -f "$DB" "$GV" >/dev/null 2>&1 || true; rm -rf "$TMP"; }
trap cleanup EXIT
cleanup_pre() { docker rm -f "$DB" >/dev/null 2>&1 || true; }; cleanup_pre

docker run -d --name "$DB" -e POSTGRES_PASSWORD=x -e POSTGRES_DB=gym postgres:16-alpine >/dev/null
for i in $(seq 1 60); do
  docker exec "$DB" pg_isready -U postgres -d gym >/dev/null 2>&1 && \
  docker exec "$DB" psql -U postgres -d gym -Atc 'select 1' >/dev/null 2>&1 && break
  sleep 1
done
docker exec -i "$DB" psql -U postgres -d gym -v ON_ERROR_STOP=1 -q < "$DDL" >/dev/null
q() { docker exec "$DB" psql -U postgres -d gym -At -F $'\t' -c "$1"; }

q "select c.relname, a.attnum, a.attname, format_type(a.atttypid,a.atttypmod), a.attnotnull
   from pg_attribute a join pg_class c on c.oid=a.attrelid join pg_namespace n on n.oid=c.relnamespace
   where n.nspname='public' and c.relkind='r' and a.attnum>0 and not a.attisdropped order by 1,2" > "$TMP/cols.tsv"
q "select c.relname, k.contype, k.conname,
          (select string_agg(a.attname, ',' order by u.ord) from unnest(k.conkey) with ordinality u(attnum,ord)
             join pg_attribute a on a.attrelid=k.conrelid and a.attnum=u.attnum),
          coalesce(r.relname,''),
          coalesce((select string_agg(a.attname, ',' order by u.ord) from unnest(k.confkey) with ordinality u(attnum,ord)
             join pg_attribute a on a.attrelid=k.confrelid and a.attnum=u.attnum),'')
   from pg_constraint k join pg_class c on c.oid=k.conrelid join pg_namespace n on n.oid=c.relnamespace
   left join pg_class r on r.oid=k.confrelid
   where n.nspname='public' and k.contype in ('p','u','f') order by 1,2,3" > "$TMP/cons.tsv"

python3 -I - "$TMP" "$HERE/4_physical_crows_foot.dot" <<'PY'
import sys, collections
tmp, out = sys.argv[1], sys.argv[2]
cols = collections.OrderedDict(); notnull = {}
for l in open(f'{tmp}/cols.tsv', encoding='utf-8'):
    t, n, a, ty, nn = l.rstrip('\n').split('\t')
    cols.setdefault(t, []).append((a, ty)); notnull[(t, a)] = (nn == 't')
pk, fks, uqs = {}, [], collections.defaultdict(list)
for l in open(f'{tmp}/cons.tsv', encoding='utf-8'):
    t, k, name, cs, rt, rcs = l.rstrip('\n').split('\t')
    cs = cs.split(',')
    if k == 'p': pk[t] = cs
    elif k == 'u': uqs[t].append((name, cs))
    else: fks.append((t, name, cs, rt, rcs.split(',')))
fkcols = collections.defaultdict(set)
for t, n, cs, rt, rcs in fks: fkcols[t].update(cs)
uqcols = collections.defaultdict(set)
for t, lst in uqs.items():
    for n, cs in lst: uqcols[t].update(cs)
esc = lambda s: s.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')
o = ['digraph PHYSICAL {',
     'graph [rankdir=LR, nodesep=0.6, ranksep=2.6, splines=true, concentrate=false, pad=0.4, fontname="DejaVu Sans", labelloc=t, fontsize=28,'
     ' label="Physical diagram - IE Crow\'s Foot (generated from Phase 3/01_schema_ddl.sql)\\n "];',
     'node [shape=plain, fontname="DejaVu Sans", fontsize=12]; edge [color="#444444", penwidth=1.3];']
for t, cl in cols.items():
    r = [f'<TR><TD COLSPAN="4" BGCOLOR="#1f4e79"><FONT COLOR="white" POINT-SIZE="15"><B> {esc(t)} </B></FONT></TD></TR>']
    for a, ty in cl:
        m = []
        if a in pk.get(t, []): m.append('PK')
        if a in fkcols[t]: m.append('FK')
        if a in uqcols[t]: m.append('UQ')
        bg = '#fff2cc' if 'PK' in m else ('#e2efda' if 'FK' in m else '#ffffff')
        nn = '' if notnull[(t, a)] or a in pk.get(t, []) else 'null'
        nm = f'<B>{esc(a)}</B>' if 'PK' in m else esc(a)
        r.append(f'<TR><TD ALIGN="LEFT" BGCOLOR="{bg}"> {",".join(m)} </TD><TD ALIGN="LEFT" BGCOLOR="{bg}" PORT="{a}"> {nm} </TD>'
                 f'<TD ALIGN="LEFT" BGCOLOR="{bg}"> {esc(ty)} </TD><TD ALIGN="LEFT" BGCOLOR="{bg}">{('<I>'+nn+'</I>') if nn else ' '}</TD></TR>')
    o.append(f'{t} [label=<<TABLE BORDER="1" CELLBORDER="0" CELLSPACING="0" CELLPADDING="3">{"".join(r)}</TABLE>>];')
for t, name, cs, rt, rcs in fks:
    one = set(cs) == set(pk.get(t, [])) or any(set(cs) == set(u) for _, u in uqs[t])
    mand = all(notnull[(t, c)] for c in cs)
    child = 'teeodot' if one else ('crowtee' if mand else 'crowodot')
    parent = 'teetee' if mand else 'teeodot'
    o.append(f'{t} -> {rt} [dir=both, arrowtail={child}, arrowhead={parent}, tooltip="{name}"];')
o.append('LEGEND [shape=plain, label=<<TABLE BORDER="1" CELLBORDER="0" CELLSPACING="0" CELLPADDING="3">'
         '<TR><TD ALIGN="LEFT"><B>Legend</B></TD></TR>'
         '<TR><TD ALIGN="LEFT">PK = primary key, FK = foreign key, UQ = unique column; null = nullable column</TD></TR>'
         '<TR><TD ALIGN="LEFT">Crow\'s foot end = many side; tee = exactly one; circle = optional (zero)</TD></TR>'
         '<TR><TD ALIGN="LEFT">Line from child FK to referenced parent PK</TD></TR></TABLE>>];')
o.append('}')
open(out, 'w', encoding='utf-8').write('\n'.join(o))
PY

docker run --rm --name "$GV" -u "$(id -u):$(id -g)" -v "$HERE":/w -w /w "$GVIMG" sh -c \
  "dot -Tsvg 4_physical_crows_foot.dot -o 4_physical_crows_foot.svg && dot -Tpng -Gdpi=$DPI 4_physical_crows_foot.dot -o 4_physical_crows_foot.png"
echo "Da tao: $HERE/4_physical_crows_foot.{dot,svg,png}"
