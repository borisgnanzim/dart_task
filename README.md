# Dart Task

Application en ligne de commande de gestion de tâches, développée en Dart pur
et sans Flutter. Elle permet de créer, consulter, terminer et supprimer des
tâches, avec une sauvegarde automatique dans un fichier JSON local.

## Fonctionnalités

- Création d'une tâche avec titre, priorité et date limite optionnelle
- Priorités disponibles : `low`, `medium` et `high`
- Liste complète des tâches
- Tri par priorité ou par date limite
- Marquage d'une tâche comme terminée
- Suppression d'une tâche
- Persistance locale dans `tasks.json`
- Validation des données et erreurs métier explicites
- Événements asynchrones exposés par un `Stream<TaskEvent>`

## Prérequis

- Dart SDK `3.7.2` ou version compatible avec la contrainte du projet
- Un terminal placé à la racine du projet

Vérifier l'installation de Dart :

```bash
dart --version
```

## Installation

Récupérer le projet puis installer les dépendances de développement :

```bash
git clone https://github.com/borisgnanzim/dart_task.git
cd dart_task
dart pub get
```

## Utilisation

Depuis la racine du projet :

```bash
dart run
```

Une commande peut également être passée directement au programme, ce qui est
pratique pour les scripts :

```bash
dart run dart_task add "Preparer le rapport" high 2026-10-15
dart run dart_task list priority
```

L'application fonctionne en mode interactif. Les commandes disponibles sont :

| Commande | Description |
| --- | --- |
| `add <titre> [priorité] [YYYY-MM-DD] [urgent]` | Ajoute une tâche. La priorité par défaut est `medium`. L'option `urgent` force la priorité `high`. |
| `list` | Affiche toutes les tâches dans leur ordre de création. |
| `list priority` | Trie les tâches de la priorité la plus haute à la plus basse. |
| `list date` | Trie les tâches par date limite, les tâches sans date en dernier. |
| `done <id>` ou `complete <id>` | Marque la tâche identifiée comme terminée. |
| `delete <id>` ou `remove <id>` | Supprime la tâche identifiée. |
| `help` | Affiche un rappel des commandes principales. |
| `quit` ou `exit` | Ferme l'application. |

Exemple de session :

```text
> add "Preparer le rapport" high 2026-10-15
Tache ajoutee: 1729000000000000

> add Repondre aux emails low
Tache ajoutee: 1729000000000001

list priority
[ ] 1729000000000000 | high | 2026-10-15 | Preparer le rapport
[ ] 1729000000000001 | low | - | Repondre aux emails

done 1729000000000000
Tache terminee.

delete 1729000000000001
Tache supprimee.
```

Le titre peut contenir plusieurs mots. Lorsqu'une priorité ou une date est
fournie, elles doivent être placées à la fin de la commande `add`. L'option
`urgent` peut être placée en dernière position.

Les données sont sauvegardées dans `tasks.json` à côté du projet. Ce fichier
est créé automatiquement au premier ajout et peut être supprimé pour repartir
d'une liste vide.

## Architecture

Le code est organisé autour de quatre éléments :

- `Task` est une classe abstraite représentant le contrat commun d'une tâche.
- `StandardTask` et `UrgentTask` illustrent l'héritage et la sérialisation du
	type concret.
- `Repository<T>` est l'interface générique de stockage. `JsonTaskRepository`
	fournit son implémentation pour un fichier JSON.
- `TaskManager` contient les opérations métier et ne dépend que de
	`Repository<Task>`, ce qui facilite les tests.
- `TaskPresentation` est une extension qui fournit un résumé d'affichage et
  détecte les tâches en retard.
- `TaskManager.events` expose les changements via un `StreamController`.

Les erreurs sont signalées avec `InvalidTaskException`,
`TaskNotFoundException` et `TaskStorageException`.

## Tests

```bash
dart test
```

La suite couvre notamment :

- l'ajout et la persistance d'une tâche ;
- la conservation des priorités et des dates ;
- le tri par priorité ;
- la terminaison et la suppression ;
- les erreurs de validation et les identifiants inconnus ;
- la restauration d'une `UrgentTask` depuis le JSON.
- les événements asynchrones et les extensions Dart.

Pour vérifier également le code avec l'analyseur Dart :

```bash
dart analyze
```
