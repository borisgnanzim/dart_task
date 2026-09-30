# Dart Task

Application CLI de gestion de taches en Dart pur.

## Lancer

Depuis la racine du projet :

```bash
dart run
```

Commandes disponibles : `add`, `list`, `done`, `delete`, `help` et `quit`.
Les donnees sont conservees dans `tasks.json`.

Exemple :

```text
add "Preparer le rapport" high 2026-10-15
list priority
done <id>
delete <id>
```

## Tester

```bash
dart test
```

Le projet utilise une classe abstraite `Task` et son implementation `UrgentTask`,
l'interface generique `Repository<T>`, des exceptions personnalisees et une
persistance JSON locale.
