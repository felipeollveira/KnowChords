# Know Chords

Aplicativo Flutter para montar progressoes de acordes por tom, com transposicao automatica da sequencia escolhida.

## 1. Visao Geral Do Sistema

O Know Chords ajuda musicos a:

- escolher um tom base;
- visualizar os acordes diatonicos daquele tom;
- montar uma sequencia de acordes com repeticao permitida;
- trocar o tom e manter a mesma estrutura harmonica por indice (transposicao).

No estado atual, o app possui duas abas:

- Home: fluxo principal de selecao de tom e montagem de progressao;
- Salvos: tela preparada para futura persistencia de acordes/progressoes.

## 2. Funcionalidades Implementadas

### 2.1 Selecao De Tom

- Tons disponiveis: `C`, `C#`, `D`, `Eb`, `E`, `F`, `F#`, `G`, `Ab`, `A`, `B`, `Bb`.
- A selecao pode ser desmarcada ao tocar novamente no mesmo tom.

### 2.2 Lista De Acordes Por Tom

- Cada tom retorna 6 acordes (estrutura maior basica, sem grau diminuto).
- Os acordes sao carregados por regra fixa no modulo de dados.

### 2.3 Montagem De Sequencia

- O usuario pode adicionar acordes em ordem livre.
- Repeticao e permitida (exemplo: `I-V-vi-V`).
- Cada item da sequencia pode ser removido individualmente.
- Existe acao para limpar toda a lista.

### 2.4 Transposicao Automatizada

- A sequencia salva internamente guarda indices dos graus selecionados.
- Ao trocar o tom, os mesmos indices sao aplicados ao novo conjunto de acordes.
- Isso preserva a funcao harmonica da progressao entre tons.

### 2.5 Tela De Salvos (Placeholder)

- A aba de salvos exibe estado vazio no momento.
- Estrutura pronta para receber estado global/persistencia futuramente.

## 3. Arquitetura Atual

Arquitetura simples em camadas leves:

- Entrada do app e navegacao: `lib/main.dart`.
- Dados harmonicos estaticos: `lib/data/acordes.dart`.
- Telas: `lib/screens/`.
- Componentes reutilizaveis de UI: `lib/widgets/`.

### 3.1 Navegacao

- `MaterialApp` com `NavigationBar` inferior.
- Indice da aba controlado por estado local em `AcordesApp`.

### 3.2 Estado

- Estado local com `StatefulWidget` na `HomeScreen`.
- Sem gerenciamento global (Provider, Riverpod, Bloc) no momento.

### 3.3 Persistencia

- Ainda nao implementada.
- Nenhum banco local/remoto configurado.

## 4. Estrutura De Pastas Relevante

```text
lib/
	main.dart
	data/
		acordes.dart
	screens/
		home_screen.dart
		salvos_screen.dart
	widgets/
		seletor_tom.dart
		lista_acordes.dart
		acordes_selecionados.dart
test/
	widget_test.dart
```

## 5. Regras De Negocio

1. O tom selecionado define o conjunto base de acordes visiveis.
2. A sequencia e armazenada por indice do acorde dentro do tom.
3. Troca de tom nao altera os indices da sequencia, apenas os nomes exibidos.
4. Sem tom selecionado, a lista de acordes nao e exibida.

## 6. Stack Tecnologica

- Flutter (Material 3)
- Dart SDK `^3.5.1`
- Dependencia de UI adicional:
	- `cupertino_icons`

Dependencias de desenvolvimento:

- `flutter_test`
- `flutter_launcher_icons`

## 7. Como Executar O Projeto

### 7.1 Pre-requisitos

- Flutter SDK instalado e configurado no PATH.
- Um dispositivo/emulador disponivel.

### 7.2 Passos

```bash
flutter pub get
flutter run
```

### 7.3 Build De Producao (exemplos)

```bash
flutter build apk
flutter build ios
flutter build windows
```

## 8. Qualidade E Testes

Comandos recomendados:

```bash
flutter analyze
flutter test
```

O projeto possui um teste base em `test/widget_test.dart`, que pode ser expandido para cobrir:

- selecao/desselecao de tom;
- adicao/remocao de acordes;
- comportamento de transposicao ao trocar o tom.

## 9. Melhorias Sugeridas

1. Implementar persistencia de progressoes (ex.: `shared_preferences` ou SQLite).
2. Criar entidade de progressao com nome, tom, data e sequencia.
3. Adicionar exportacao/compartilhamento de progressoes.
4. Incluir acordes de setima e variacoes harmonicas.
5. Cobrir regras principais com testes de widget e testes unitarios.

## 10. Status Atual

- Versao funcional para montagem e transposicao de progressoes.
- Escopo principal de estudo harmonico implementado.
- Modulo de salvos pronto para evolucao.
