# 🚗 Estacionamento Rotativo

Aplicativo mobile desenvolvido em **Flutter** para gerenciamento de estacionamento rotativo, com controle de usuários, veículos, tempo de permanência e saldo. Utiliza **Firebase** para autenticação e persistência de dados e segue a arquitetura em camadas: **View**, **BLoC**, e **Provider**.

## 📱 Funcionalidades

- Cadastro e login de usuários
- Cadastro de veículos
- Visualização e gerenciamento de veículos cadastrados
- Controle de saldo da carteira digital
- Navegação por abas (Início, Adicionar, Veículos, Saldo)
- Interface moderna com design responsivo
- Armazenamento em nuvem com Firestore

## 🧠 Arquitetura

O projeto segue a separação em **3 camadas principais**:

- **View**: Interface do usuário (UI) construída com widgets do Flutter
- **BLoC**: Controle de estado para autenticação e usuário (Login, Registro, Sessão)
- **Provider**: Gerenciamento de dados de veículos e saldo da carteira

## 📚 O que foi aprendido

Durante o desenvolvimento deste projeto, foram praticados os seguintes aprendizados:

- Como construir interfaces responsivas com **Flutter**
- Integração completa com **Firebase Authentication** e **Cloud Firestore**
- Separação de responsabilidades com arquitetura em camadas (View, BLoC, Provider)
- Gerenciamento de estado com **flutter_bloc** e **Provider**
- Validação de formulários e controle de fluxo de navegação
- Modularização e organização de código em projetos reais
- Tratamento de exceções e exibição de feedback ao usuário
- Criação de um fluxo completo de login, registro e sessão

## 🛠️ Tecnologias Utilizadas

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Provider
- flutter_bloc
- Material Design
