import UnityPy
import json
import sys
import os

# Chemin vers le fichier save
infile = "user1.dat"
if len(sys.argv) >= 2:
    infile = sys.argv[1]

if not os.path.isfile(infile):
    print("Fichier introuvable :", infile)
    sys.exit(1)

env = UnityPy.load(infile)

# Fonction récursive pour sérialiser tous les objets en JSON
def serialize(obj, visited=None):
    if visited is None:
        visited = set()
    oid = id(obj)
    if oid in visited:
        return "<recursion>"
    visited.add(oid)

    try:
        if obj is None or isinstance(obj, (bool, int, float, str)):
            visited.remove(oid)
            return obj
        if isinstance(obj, (bytes, bytearray)):
            s = obj.decode("utf-8", errors="ignore")
            visited.remove(oid)
            return s
        if isinstance(obj, (list, tuple, set)):
            res = [serialize(x, visited) for x in obj]
            visited.remove(oid)
            return res
        if isinstance(obj, dict):
            d = {}
            for k, v in obj.items():
                d[str(k)] = serialize(v, visited)
            visited.remove(oid)
            return d
        # essayer d'accéder aux attributs courants UnityPy
        for attr in ("save", "serialized", "typetree", "m_Data", "m_ByteArray", "data"):
            if hasattr(obj, attr):
                try:
                    val = getattr(obj, attr)
                    res = serialize(val, visited)
                    visited.remove(oid)
                    return res
                except Exception:
                    pass
        # fallback : __dict__ ou str
        if hasattr(obj, "__dict__"):
            d = {}
            for k, v in obj.__dict__.items():
                d[str(k)] = serialize(v, visited)
            visited.remove(oid)
            return d
        s = str(obj)
        visited.remove(oid)
        return s
    except Exception as e:
        visited.discard(oid)
        return f"<serialize error: {e}>"

# Écriture de tous les objets dans un seul fichier
with open("save_dump.txt", "w", encoding="utf-8") as out:
    for idx, obj in enumerate(env.objects):
        typ = getattr(obj, "type", None)
        tname = getattr(typ, "name", str(typ))
        pid = getattr(obj, "path_id", None)
        out.write(f"\n==== OBJECT {idx} ====\n")
        out.write(f"type: {tname}\npath_id: {pid}\n")
        try:
            data = obj.read()
            ser = serialize(data)
            out.write(json.dumps(ser, ensure_ascii=False, indent=2))
            out.write("\n")
        except Exception as e:
            out.write(f"ERROR reading/serializing object: {e}\n")
            try:
                out.write(repr(obj) + "\n")
            except:
                pass

print("✅ Conversion terminée, tout le contenu écrit dans save_dump.txt")
