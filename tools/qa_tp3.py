"""Contrôle le sujet TP3, l'archive et les blocs Bash, sans solutions élèves."""
from pathlib import Path
import re
import xml.etree.ElementTree as ET
from zipfile import ZipFile

ROOT = Path(__file__).resolve().parents[1]
SUBJECT = ROOT / 'docs/eleves/tp3-programmer-bash.md'
TOOLS = ('factorielle', 'factorielle_recursif', 'afficher_nom', 'afficher_contenu',
         'mon_seq', 'calculatrice', 'mon_cat', 'tester_script')
PREPARATION = ('repere', 'parametres', 'enfant', 'statut', 'parite', 'depart', 'somme',
               'concatenation', 'triangle', 'parametres2', 'arguments3', 'executables')


def main():
    subject = SUBJECT.read_text(encoding='utf-8')
    carnet = (ROOT / 'docs/assets/tp3-modele-notes.txt').read_text(encoding='utf-8-sig')
    helper = (ROOT / 'tools/tp3_verifier.sh').read_text(encoding='utf-8')
    assert not re.search(r'ancien(?:ne)?s? (?:TP|TD|cours|sujet|exercice)', subject, re.I)
    assert not re.search(r'Question - N\d+', subject)
    assert 'facultatif' in carnet and 'N01' not in carnet
    assert len(re.findall(r'^## Niveau \d+ —', subject, re.M)) == 13
    headings = re.findall(r'^## Niveau (\d+) — [^\n`]*`([^`\n]+)\.sh`', subject, re.M)
    assert [(str(i + 5), name) for i, name in enumerate(TOOLS)] == [x for x in headings if int(x[0]) >= 5]
    for name in PREPARATION + TOOLS:
        assert name + '.sh' in subject, name
        assert name in helper.split('programmes=(')[1].split(')')[0], name
    for target in re.findall(r'\]\(([^)]+)\)', subject):
        if '://' not in target and not target.startswith('#'):
            assert (SUBJECT.parent / target.split('#')[0]).resolve().is_file(), target
    for path in (ROOT / 'docs/index.md', ROOT / 'mkdocs.yml'):
        assert 'eleves/tp3-programmer-bash.md' in path.read_text(encoding='utf-8')
    ET.parse(ROOT / 'docs/assets/tp3-conditions.svg')
    with ZipFile(ROOT / 'docs/assets/tp3-atelier-decisions.zip') as archive:
        assert archive.testzip() is None
        names = archive.namelist()
        assert len(names) == len(set(names))
        assert all(n.startswith('atelier-decisions/') and '..' not in n for n in names)
        assert not any(n.endswith('.sh') and ('/scripts/' in n or '/preparation/' in n) for n in names)
        assert archive.read('atelier-decisions/verifier.sh').decode('utf-8') == helper
        assert len([n for n in names if n.endswith('.sh')]) == 2
        for name in names:
            data = archive.read(name)
            assert b'\r' not in data, name
            assert not re.search(rb'ancien(?:ne)?s? (?:TP|TD|cours)', data, re.I), name
        prefix = 'atelier-decisions/donnees/'
        assert archive.read(prefix + 'vide.txt') == b''
        assert not archive.read(prefix + 'sans-retour.txt').endswith(b'\n')
        assert archive.read(prefix + 'morceau-a.txt') + archive.read(prefix + 'morceau-b.txt') == b'debut suite\n'
        assert archive.read(prefix + 'espaces.txt') == b'  chemin C:\\relais\\nord  \n'
    blocks = re.findall(r'^```bash\n(.*?)^```', subject, re.M | re.S)
    destination = ROOT / '.cache/tp3-qa/bash-blocs'
    destination.mkdir(parents=True, exist_ok=True)
    for old in destination.glob('bloc-*.sh'):
        old.unlink()
    for i, block in enumerate(blocks, 1):
        (destination / f'bloc-{i:02d}.sh').write_bytes(block.encode('utf-8'))
    print(f'TP3 : 13 niveaux, 20 programmes, aucun questionnaire ; {len(blocks)} blocs Bash à vérifier.')
    print('Archive, vérificateur, carnet et liens cohérents.')


if __name__ == '__main__':
    main()
