# Boilerplate de Automação Mobile com Maestro

Este é um boilerplate completo para automação de testes mobile utilizando **Maestro**, projetado para testes funcionais, fluxos críticos e validações end-to-end (E2E) em aplicativos Android e iOS.

## Índice

- [Introdução](#introdução)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Pré-requisitos](#pré-requisitos)
- [Instalação](#instalação)
- [Como Usar](#como-usar)
- [Padrões e Boas Práticas](#padrões-e-boas-práticas)
- [Ambientes](#ambientes)
- [CI/CD](#cicd)
- [Integração com Cucumber](#integração-com-cucumber)

## Introdução

Este boilerplate oferece:

- Estrutura de diretórios padronizada e escalável
- Separação clara entre flows, actions, pages e variáveis
- Suporte para múltiplos ambientes (local, QA, HML)
- Scripts de execução prontos para uso
- Padrões de escrita YAML otimizados
- Integração com CI/CD (GitHub Actions)
- Estratégia de gerenciamento de massa de dados

## Estrutura do Projeto

```
.
├── .maestro/
│   ├── flows/                    # Testes E2E completos
│   │   ├── login/
│   │   │   ├── login-success.yml
│   │   │   └── login-invalid.yml
│   │   └── pagamentos/
│   │       ├── pagar-boleto.yml
│   │       └── agendar-pagamento.yml
│   ├── include/
│   │   ├── actions/              # Ações reutilizáveis
│   │   │   ├── common-actions.yml
│   │   │   ├── login-actions.yml
│   │   │   └── pagamento-actions.yml
│   │   ├── pages/                # Page Objects (IDs e seletores)
│   │   │   ├── login-page.yml
│   │   │   ├── home-page.yml
│   │   │   └── pagamentos-page.yml
│   │   └── variables/            # Variáveis por ambiente
│   │       ├── global-variables.yml
│   │       ├── qa.yml
│   │       ├── hml.yml
│   │       └── local.yml
│   ├── test-data/                # Dados estáticos (JSON)
│   │   ├── usuarios.json
│   │   └── pagamentos.json
│   ├── reports/                  # Relatórios gerados
│   └── screenshots/              # Screenshots de falhas
├── scripts/
│   ├── run-local.sh              # Execução local
│   ├── run-device.sh             # Execução em device físico
│   └── run-ci.sh                 # Execução em CI/CD
├── maestro-config.yaml           # Configuração global
├── .env.example                  # Exemplo de variáveis de ambiente
├── .gitignore
└── README.md
```

## Pré-requisitos

- **Maestro CLI**: [Instalação](https://maestro.mobile.dev/getting-started/installing-maestro)
- **Android SDK** (para Android)
- **Java 11+**
- **Node.js 16+** (opcional, para integrações)
- **Git**

### Verificar instalação do Android SDK

```bash
echo $ANDROID_HOME
```

## Instalação

### 1. Instalar Maestro

```bash
curl -Ls "https://get.maestro.mobile.dev" | bash
```

Verificar instalação:

```bash
maestro --version
```

### 2. Clonar o repositório

```bash
git clone https://github.com/mob4pay/Automacao-Mobile.git
cd Automacao-Mobile
```

### 3. Configurar ambiente

Copie o arquivo de exemplo e configure suas variáveis:

```bash
cp .env.example .env
```

Edite o arquivo `.env` com suas configurações.

### 4. Configurar emulador Android (opcional)

```bash
emulator -avd Pixel_6_API_33 &
```

## Como Usar

### Executar um teste específico

```bash
maestro test .maestro/flows/login/login-success.yml --env qa
```

### Executar todos os testes

```bash
maestro test .maestro/flows --env qa
```

### Executar testes com tags

```bash
# Apenas testes smoke
maestro test .maestro/flows --include-tags smoke --env qa

# Teste específico por tag
maestro test .maestro/flows --include-tags LOGIN_001 --env qa
```

### Usando scripts prontos

#### Execução Local

```bash
chmod +x scripts/run-local.sh
./scripts/run-local.sh --env local
```

#### Execução em Device Físico

```bash
chmod +x scripts/run-device.sh
./scripts/run-device.sh --env qa --device <device_id>
```

#### Execução em CI/CD

```bash
chmod +x scripts/run-ci.sh
./scripts/run-ci.sh --env qa --tags smoke
```

## Padrões e Boas Práticas

### Flows

- Um diretório por feature
- Nomes descritivos: `<feature>/<ação>-<resultado>.yml`
- Máximo 30-40 linhas por flow
- Apenas orquestração, sem lógica repetida

### Pages

- Equivalente ao Page Object Pattern
- IDs e seletores agrupados por tela
- Nomes claros: `input_email`, `btn_login`, `txt_saldo`

### Actions

- Ações reutilizáveis
- Nomes em verbo: `realizar-login`, `scroll-ate-fim`
- Tudo que repete mais de uma vez vira action

### Variables

- Um arquivo por ambiente
- `camelCase` para nomes de variáveis
- Nunca colocar credenciais reais
- `global-variables.yml` para elementos comuns

### Test Data

- Apenas arquivos JSON
- Separar por contexto: `usuarios.json`, `pagamentos.json`
- Nunca versionar dados sensíveis

## Ambientes

O projeto suporta múltiplos ambientes através de arquivos de variáveis:

- **local**: Desenvolvimento local
- **qa**: Ambiente de testes
- **hml**: Homologação

Para executar em um ambiente específico:

```bash
maestro test .maestro/flows --env qa
```

## CI/CD

### GitHub Actions (exemplo básico)

```yaml
name: Mobile Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up JDK 11
        uses: actions/setup-java@v3
        with:
          java-version: '11'
          
      - name: Install Maestro
        run: curl -Ls "https://get.maestro.mobile.dev" | bash
        
      - name: Run Tests
        run: ./scripts/run-ci.sh --env qa --tags smoke
        
      - name: Upload Reports
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: test-reports
          path: .maestro/reports/
```

## Integração com Cucumber

Os testes podem ser documentados com Cucumber (Gherkin) e executados via Maestro usando tags:

**Cucumber (.feature)**:
```gherkin
@LOGIN_001
Scenario: Login com sucesso
  When insiro credenciais válidas
  Then vejo "Bem-vindo"
```

**Maestro (.yml)**:
```yaml
tags:
  - LOGIN_001

flow:
  - runFlow: ../include/actions/login-actions.yml
  - assertVisible: "Bem-vindo"
```

## Relatórios

Os relatórios são gerados automaticamente em:

- **JUnit XML**: `.maestro/reports/`
- **Screenshots**: `.maestro/screenshots/` (apenas em falhas)
- **Logs**: `.maestro/reports/logcat.txt` (em falhas)

## Contribuindo

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -m 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

## Licença

Este projeto está sob a licença MIT.

## Contato

Para dúvidas ou sugestões, entre em contato com a equipe de QA.

---

**Desenvolvido por Mob4Pay**