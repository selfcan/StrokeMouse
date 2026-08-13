---
title: "Actions"
description: "Actions StrokeMouse : raccourcis, ouvrir une app, URL, touches média, fenêtres, Shell et AppleScript."
titleTemplate: "StrokeMouse"
---

# Actions

En cas de correspondance, `ActionExecutor` dispatche l’action configurée.

## Vue d’ensemble

| Type | Rôle | Notes |
|------|----------------|-------|
| Aucune | Correspondance seule / test | — |
| **Raccourci** | Injecter un accord de touches | Nécessite l’Accessibilité |
| **Ouvrir une app** | Choisir une app installée par icône et la lancer | Stocké comme bundle id |
| **Ouvrir une URL** | Navigateur / gestionnaire par défaut | — |
| **Média** | Lecture/pause, pistes, volume, sourdine | — |
| **Fenêtre** | Fermer, réduire, zoomer, plein écran, masquer, centrer | Nécessite AX |
| **Shell** | Exécuter une commande shell (éditeur coloré) | **Privilège élevé** |
| **AppleScript** | Préréglages intégrés ou script perso (coloré) | **Privilège élevé** ; Automatisation parfois requise |

## Raccourci

Les raccourcis se règlent uniquement par enregistrement ; le champ d’affichage est en lecture seule. Cliquez **Enregistrer**, pressez les touches dans l’ordre voulu, puis relâchez-les toutes. Esc seul annule.

Les raccourcis avec une touche normale (par ex. `⌘⌥Q`) et ceux composés uniquement de modificateurs (par ex. `⌘⌥`) sont pris en charge. Le résultat s’affiche dans l’ordre d’appui. Les modificateurs pris en charge sont Command, Option, Control et Shift.

## Ouvrir une app

Dans le sélecteur d’action, choisissez parmi les **apps installées** par icône (recherche ou parcours d’un `.app`) — pas besoin de taper un bundle id à la main (le lancement utilise quand même l’identifiant de paquet). Le nom affiché sert à la liste.

## Ouvrir une URL

Toute URL que le système peut ouvrir. Le geste par défaut « Ouvrir GitHub » utilise ce type.

## Média

| Commande | Rôle |
|---------|------|
| playPause | Lecture / pause |
| nextTrack / previousTrack | Sauter |
| volumeUp / volumeDown / mute | Volume |

## Fenêtre

| Commande | Rôle |
|---------|------|
| close | Fermer la fenêtre |
| minimize | Réduire |
| zoom | Zoom (sémantique du bouton vert) |
| fullscreen | Plein écran |
| hide | Masquer l’app |
| center | Centrer la fenêtre |

Cible en général la fenêtre de premier plan ; échoue si AX est indisponible.

## Shell

Exécute une chaîne de commande locale. L’éditeur colore la syntaxe pour relire plus facilement les longues commandes.

::: danger Risque
Le Shell a votre pouvoir utilisateur sur les fichiers et processus. Ne collez que des commandes que vous comprenez et en lesquelles vous avez confiance.
:::

## AppleScript

Utilisez un **préréglage intégré** (sommeil, vider la Corbeille, verrouiller l’écran, économiseur, se déconnecter / redémarrer / éteindre, basculer le mode sombre, masquer les autres, sourdine / rétablir, panneau Forcer à quitter, capture vers le presse-papiers, ouvrir Téléchargements) ou passez à un script **personnalisé**. Contrôler d’autres apps peut exiger l’**Automatisation**. L’éditeur colore aussi la syntaxe.

::: danger Risque
Même classe de risque que le Shell. N’exécutez jamais de scripts non fiables.
:::

## Bien choisir

| Objectif | Préférer |
|------|--------|
| Raccourcis système / d’app | Raccourci |
| Lancer un logiciel | Ouvrir une app |
| Saut façon signet | Ouvrir une URL |
| Musique et volume | Média |
| Gestion des fenêtres | Fenêtre |
| Automatisation lourde | Shell / AppleScript (avec prudence) |

Persistance : [Fichier de config](./config-file).
