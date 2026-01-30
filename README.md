# Documentação Inicial do Projeto: Marketplace de Pagamentos

## Sumário

1. [Visão Geral](#visão-geral)
2. [Conceito do Negócio](#conceito-do-negócio)
3. [Tipos de Usuários](#tipos-de-usuários)
4. [Cenário do Vendedor](#cenário-do-vendedor)
5. [Cenário do Administrador](#cenário-do-administrador)
6. [Fluxo de Pagamento](#fluxo-de-pagamento)
7. [Sistema de Taxas](#sistema-de-taxas)
8. [Sistema de Reservas Financeiras](#sistema-de-reservas-financeiras)
9. [Entidades Principais](#entidades-principais)
10. [Integrações Externas](#integrações-externas)

---

## Visão Geral

Este projeto é um **marketplace de pagamentos** (também conhecido como PSP - Payment Service Provider) voltado para o mercado brasileiro. A plataforma permite que vendedores/comerciantes recebam pagamentos de seus clientes via **PIX**, gerenciem suas finanças e realizem saques.

### O que o sistema faz?

- Permite que vendedores criem **links de pagamento** para cobrar seus clientes
- Processa pagamentos via **PIX** através de múltiplos gateways (Podendo ter cartão, boleto, etc)
- Gerencia a **carteira digital** dos vendedores (saldos, reservas, saques)
- Oferece um **painel administrativo** completo para gestão da plataforma
- Cobra **taxas** sobre as transações realizadas

---

## Conceito do Negócio

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│   CLIENTE                 PLATAFORMA                    VENDEDOR            │
│   (comprador)            (marketplace)                  (lojista)           │
│                                                                             │
│   ┌─────────┐           ┌─────────────┐              ┌─────────────┐        │
│   │         │  Paga via │             │  Recebe o    │             │        │
│   │ Cliente │ ────────> │  Plataforma │ ──────────>  │  Vendedor   │        │
│   │         │    PIX    │             │   valor      │             │        │
│   └─────────┘           └─────────────┘  (- taxas)   └─────────────┘        │
│                               │                                             │
│                               │                                             │
│                         ┌─────▼─────┐                                       │
│                         │  Gateway  │                                       │
│                         │    PIX    │                                       │
│                         └───────────┘                                       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Resumo do Modelo de Negócio

1. **Vendedores** se cadastram na plataforma e passam por verificação (KYC)
2. Após aprovação, podem criar **links de pagamento** com valores específicos
3. **Clientes** acessam esses links e pagam via PIX
4. A plataforma recebe o pagamento, **desconta suas taxas** e credita na carteira do vendedor
5. O vendedor pode **solicitar saques** para sua conta PIX

---

## Tipos de Usuários

O sistema possui **dois tipos principais** de usuários:

| Tipo                  | Descrição                                                        | Acesso                   |
| --------------------- | ---------------------------------------------------------------- | ------------------------ |
| **Vendedor (Seller)** | Comerciante/lojista que usa a plataforma para receber pagamentos | Dashboard do Vendedor    |
| **Administrador**     | Equipe interna que gerencia a plataforma                         | Dashboard Administrativo |

### Níveis de Administrador

Os administradores possuem diferentes níveis de permissão:

- **Super Admin**: Acesso total ao sistema
- **Admin**: Acesso amplo, mas com algumas restrições
- **Manager**: Acesso limitado a operações do dia-a-dia

---

## Cenário do Vendedor

### Jornada do Vendedor

```
Cadastro → Envio de Documentos → Aguarda Aprovação → Aprovado → Usa a Plataforma
```

### Processo de Onboarding (Cadastro)

O vendedor passa por um processo de cadastro em **7 etapas**:

1. **Dados da Empresa**: CNPJ, razão social, nome fantasia
2. **Endereço**: Endereço completo da empresa
3. **Contato**: Email, telefone, site
4. **Representante Legal**: Dados do responsável pela empresa
5. **Dados Bancários**: Chave PIX para receber saques
6. **Documentos**: Upload de documentos (contrato social, RG, selfie com RG)
7. **Revisão**: Conferência de todos os dados antes do envio

Após o envio, o cadastro fica com status **"Pendente"** aguardando aprovação de um administrador.

### Páginas do Dashboard do Vendedor

#### 1. Visão Geral

**O que é**: Página inicial do vendedor com resumo das informações.

**O que mostra**:

- Total de vendas do dia (quantidade e valor)
- Saldo disponível para saque
- Saldo em reserva
- Gráficos de vendas recentes
- Últimas transações

---

#### 2. Links de Pagamento

**O que é**: Gerenciamento dos links de cobrança.

**O que o vendedor pode fazer**:

- **Criar** novos links de pagamento informando:
  - Nome (ex: "Compra de Produto X")
  - Descrição (ex: "Serviço Y")
  - Valor do pagamento
- **Visualizar** todos os links criados
- **Ativar/Desativar** links existentes
- **Copiar** o link para compartilhar com clientes
- **Ver** quantos pagamentos cada link recebeu

**Como funciona o link**:

- Cada link possui um **código único** (hash)
- O cliente acessa o link e vê uma página de checkout
- Ao pagar, um **QR Code PIX** é gerado
- Após o pagamento, o contador do link é incrementado

---

#### 3. Carteira

**O que é**: Gestão financeira do vendedor.

**O que mostra**:

- **Saldo Disponível**: Valor que pode ser sacado
- **Saldo em Reserva**: Valor retido temporariamente (explicado mais abaixo)
- **Saldo Pendente**: Pagamentos ainda não confirmados

**O que o vendedor pode fazer**:

- Visualizar o extrato de movimentações
- Ver detalhes das reservas (quando serão liberadas)
- **Solicitar saque** do saldo disponível

**Regras de Saque**:

- Valor mínimo: R$ 12,00
- Valor máximo: R$ 5.000,00 por saque
- O saque é enviado para a chave PIX cadastrada

---

#### 4. Transações

**O que é**: Histórico completo de todas as transações.

**O que mostra**:

- Lista de todos os pagamentos recebidos
- Status de cada transação (Aprovado, Pendente, Falhou)
- Valor bruto, taxas cobradas, valor líquido
- Data e hora de cada transação
- Dados do cliente que pagou

**Filtros disponíveis**:

- Por período (data inicial e final)
- Por status
- Por link de pagamento

---

#### 5. Clientes

**O que é**: Gestão dos clientes que já pagaram.

**O que mostra**:

- Lista de todos os clientes que fizeram pagamentos
- Nome, email, telefone, CPF/CNPJ de cada cliente

**Observação**: Os dados dos clientes são coletados automaticamente durante o checkout.

---

#### 6. Integrações

**O que é**: Ferramentas para integração técnica.

**O que o vendedor pode fazer**:

**Credenciais de API**:

- Gerar chaves de API (pública e privada)
- Usar as chaves para integrar com sistemas próprios

**Webhooks**:

- Cadastrar URLs para receber notificações
- Receber avisos automáticos quando um pagamento é confirmado

---

#### 7. Taxas (`/dashboard/seller/fees`)

**O que é**: Informações sobre as taxas cobradas.

**O que mostra**:

- Taxa percentual cobrada por transação (ex: 2,5%)
- Taxa fixa por transação (ex: R$ 0,50)
- Exemplos de cálculo

---

#### 8. Minha Empresa (`/dashboard/seller/enterprise`)

**O que é**: Dados cadastrais da empresa.

**O que mostra**:

- Todos os dados da empresa cadastrados
- Status do cadastro (Aprovado, Pendente, Rejeitado)
- Documentos enviados

**O que o vendedor pode fazer**:

- Visualizar seus dados
- Solicitar alterações (dependendo das regras do sistema)

---

## Cenário do Administrador

### Páginas do Dashboard Administrativo

#### 1. Visão Geral

**O que é**: Dashboard principal com métricas do sistema.

**O que mostra**:

- Total de transações do dia/mês
- Volume financeiro processado
- Quantidade de vendedores ativos
- Quantidade de saques pendentes
- Gráficos de performance

---

#### 2. Empresas/Vendedores

**O que é**: Gestão de todos os vendedores cadastrados.

**O que o admin pode fazer**:

- **Listar** todos os vendedores
- **Visualizar** detalhes de cada vendedor
- **Aprovar** cadastros pendentes
- **Rejeitar** cadastros (informando motivo)
- **Bloquear** vendedores ativos
- **Desbloquear** vendedores bloqueados
- **Editar** dados dos vendedores
- **Configurar taxas** específicas para cada vendedor

---

#### 3. KYC - Verificação

**O que é**: Análise de documentos dos vendedores.

**O que o admin pode fazer**:

- Visualizar documentos enviados (contrato social, RG, selfie)
- Consultar CNPJ em bases públicas
- Aprovar ou rejeitar a documentação
- Solicitar novos documentos se necessário

---

#### 4. Saques

**O que é**: Gestão de solicitações de saque.

**Status de um saque**:

- **Solicitado**: Vendedor pediu o saque
- **Em Processamento**: Admin está processando
- **Concluído**: Dinheiro enviado com sucesso
- **Rejeitado**: Saque negado pelo admin
- **Falhou**: Erro no envio

**O que o admin pode fazer**:

- Visualizar todos os saques solicitados
- **Aprovar** saques (envia o dinheiro)
- **Rejeitar** saques (informando motivo)
- Marcar saques como concluídos manualmente
- Filtrar por status, data, vendedor

---

#### 5. Equipe

**O que é**: Gestão dos administradores do sistema.

**O que o admin pode fazer**:

- Adicionar novos administradores
- Definir nível de permissão (Super Admin, Admin, Manager)
- Remover administradores
- Editar permissões

---

#### 6. Configurações

**O que é**: Configurações gerais do sistema.

**O que pode ser configurado**:

**Branding/Identidade Visual**:

- Logo da plataforma
- Favicon
- Cores do tema (claro e escuro)

**Configurações de Reserva**:

- Percentual de reserva (ex: 15%)
- Período de retenção (ex: 120 dias)
- Ativar/desativar sistema de reservas

**Configurações de Exibição**:

- Mostrar/ocultar valores nas transações
- Mostrar/ocultar resumo de saldos

---

#### 7. Emails Personalizados

**O que é**: Templates de emails enviados pelo sistema.

**Emails configuráveis**:

- Email de boas-vindas (novo cadastro)
- Email de aprovação de cadastro
- Email de rejeição de cadastro
- Email de bloqueio de conta

---

#### 8. Gateways/Adquirentes

**O que é**: Configuração dos gateways de pagamento.

**O que o admin pode fazer**:

- Ativar/desativar gateways
- Definir qual gateway cada vendedor usa
- Configurar credenciais dos gateways

**Gateways disponíveis** (exemplo):

- Pluggou
- PagLoop
- XdPag
- Ameii
- SplitPay
- NovoPag
- Goldiix

---

#### 9. Ranking

**O que é**: Ranking dos melhores vendedores.

**O que mostra**:

- Top vendedores por volume de vendas
- Top vendedores por quantidade de transações

---

#### 10. Faturamento

**O que é**: Relatórios financeiros da plataforma.

**O que mostra**:

- Receita total em taxas
- Receita por período
- Receita por vendedor

---

#### 11. Anúncios/Banners

**O que é**: Gestão de banners promocionais.

**O que o admin pode fazer**:

- Criar banners para exibir no dashboard dos vendedores
- Definir período de exibição
- Upload de imagens

---

## Fluxo de Pagamento

### Passo a Passo Detalhado

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                           FLUXO DE PAGAMENTO                                 │
└──────────────────────────────────────────────────────────────────────────────┘

1. VENDEDOR CRIA LINK
   │
   ▼
┌─────────────────────────────────────┐
│ Vendedor acessa "Links de Pagamento"│
│ Cria link com valor: R$ 100,00      │
│ Descrição: "Produto X"              │
│ Sistema gera: pay.exemplo.com/abc123│
└─────────────────────────────────────┘
   │
   ▼
2. CLIENTE ACESSA O LINK
   │
   ▼
┌─────────────────────────────────────┐
│ Cliente abre: pay.exemplo.com/abc123│
│ Vê página de checkout               │
│ Preenche: Nome, Email, CPF, Telefone│
│ Clica em "Pagar"                    │
└─────────────────────────────────────┘
   │
   ▼
3. QR CODE PIX É GERADO
   │
   ▼
┌─────────────────────────────────────┐
│ Sistema solicita QR Code ao gateway │
│ Gateway retorna QR Code + código    │
│ Cliente vê QR Code na tela          │
│ Cliente escaneia com app do banco   │
└─────────────────────────────────────┘
   │
   ▼
4. CLIENTE PAGA NO BANCO
   │
   ▼
┌─────────────────────────────────────┐
│ Cliente confirma pagamento no app   │
│ Banco processa a transferência PIX  │
│ Dinheiro chega no gateway           │
└─────────────────────────────────────┘
   │
   ▼
5. GATEWAY NOTIFICA A PLATAFORMA (Webhook)
   │
   ▼
┌─────────────────────────────────────┐
│ Gateway envia webhook para sistema  │
│ Webhook contém: status = "APPROVED" │
│ Sistema valida a notificação        │
└─────────────────────────────────────┘
   │
   ▼
6. SISTEMA PROCESSA O PAGAMENTO
   │
   ▼
┌─────────────────────────────────────┐
│ Valor bruto: R$ 100,00              │
│ Taxa da plataforma (2,5%): R$ 2,50  │
│ Valor líquido: R$ 97,50             │
│                                     │
│ Reserva (15%): R$ 14,62             │
│ Disponível: R$ 82,88                │
└─────────────────────────────────────┘
   │
   ▼
7. SALDOS SÃO ATUALIZADOS
   │
   ▼
┌─────────────────────────────────────┐
│ Saldo disponível: + R$ 82,88        │
│ Saldo em reserva: + R$ 14,62        │
│ (Reserva libera após 120 dias)      │
└─────────────────────────────────────┘
   │
   ▼
8. CLIENTE VÊ CONFIRMAÇÃO
   │
   ▼
┌─────────────────────────────────────┐
│ Tela mostra: "Pagamento Confirmado!"│
│ Vendedor recebe notificação         │
└─────────────────────────────────────┘
```

---

## Sistema de Taxas

### Como Funcionam as Taxas

A plataforma cobra taxas sobre cada transação para se remunerar. Existem dois tipos:

| Tipo                | Descrição                             | Exemplo                  |
| ------------------- | ------------------------------------- | ------------------------ |
| **Taxa Percentual** | Percentual sobre o valor da transação | 2,5% de R$ 100 = R$ 2,50 |
| **Taxa Fixa**       | Valor fixo por transação              | R$ 0,50 por transação    |

### Cálculo de Exemplo

```
Valor da venda: R$ 100,00
Taxa percentual (2,5%): R$ 2,50
Taxa fixa: R$ 0,50
─────────────────────────────
Total de taxas: R$ 3,00
Valor líquido para vendedor: R$ 97,00
```

### Taxas Personalizadas

O administrador pode definir:

- **Taxa padrão**: Aplicada a todos os vendedores
- **Taxa específica**: Taxas diferentes para vendedores específicos (negociação comercial)

---

## Sistema de Reservas Financeiras

### O que é a Reserva?

A reserva é um **mecanismo de proteção** da plataforma. Uma porcentagem de cada pagamento fica "retida" por um período antes de ficar disponível para saque.

### Por que existe?

- Proteção contra **chargebacks** (estornos)
- Proteção contra **fraudes**
- Garantia em caso de **disputas**

### Como funciona?

```
Exemplo com reserva de 15% por 120 dias:

Pagamento recebido: R$ 100,00
Taxas: R$ 3,00
Valor líquido: R$ 97,00

Reserva (15% de R$ 97,00): R$ 14,55
Disponível imediatamente: R$ 82,45

Após 120 dias: R$ 14,55 é liberado para o saldo disponível
```

### Configurações da Reserva

| Configuração   | Descrição                     | Exemplo  |
| -------------- | ----------------------------- | -------- |
| **Percentual** | Quanto é retido de cada venda | 15%      |
| **Período**    | Quanto tempo fica retido      | 120 dias |

O administrador pode:

- Ativar ou desativar o sistema de reservas
- Definir percentual e período padrão
- Configurar valores diferentes por vendedor

---

## Entidades Principais

### Diagrama de Entidades

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  ┌──────────────┐         ┌──────────────┐         ┌──────────────┐        │
│  │    User      │────────>│  Enterprise  │────────>│  Documents   │        │
│  │  (Vendedor)  │         │  (Empresa)   │         │  (KYC docs)  │        │
│  └──────────────┘         └──────────────┘         └──────────────┘        │
│         │                        │                                          │
│         │                        │                                          │
│         ▼                        ▼                                          │
│  ┌──────────────┐         ┌──────────────┐                                  │
│  │   Seller     │         │ PaymentLink  │                                  │
│  │  Balances    │         │              │                                  │
│  └──────────────┘         └──────────────┘                                  │
│         │                        │                                          │
│         │                        ▼                                          │
│         │                 ┌──────────────┐         ┌──────────────┐        │
│         │                 │   Payment    │────────>│   Customer   │        │
│         │                 │              │         │              │        │
│         │                 └──────────────┘         └──────────────┘        │
│         │                        │                                          │
│         ▼                        ▼                                          │
│  ┌──────────────┐         ┌──────────────┐                                  │
│  │  Withdrawal  │         │   Reserve    │                                  │
│  │   (Saque)    │         │  (Retenção)  │                                  │
│  └──────────────┘         └──────────────┘                                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Descrição das Entidades

| Entidade                 | Descrição                                                   |
| ------------------------ | ----------------------------------------------------------- |
| **User**                 | Usuário do sistema (vendedor ou admin)                      |
| **Enterprise**           | Dados da empresa do vendedor (CNPJ, razão social, endereço) |
| **EnterpriseDocument**   | Documentos enviados para verificação (RG, contrato social)  |
| **PaymentLink**          | Link de pagamento criado pelo vendedor                      |
| **Payment**              | Registro de cada pagamento realizado                        |
| **SellerCustomer**       | Cliente que fez um pagamento (nome, email, CPF)             |
| **SellerBalances**       | Saldos do vendedor (disponível, reserva, pendente)          |
| **SellerReserve**        | Registro de cada reserva financeira                         |
| **Withdrawal**           | Solicitação de saque                                        |
| **SystemFees**           | Configuração de taxas                                       |
| **Acquirer**             | Gateway de pagamento configurado                            |
| **FinancialTransaction** | Log de todas as movimentações financeiras                   |

---

## Integrações Externas

### Gateways de Pagamento

A plataforma deve se integrar com múltiplos gateways para processar PIX, cartões, boletos e etc.

**Por que múltiplos gateways?**

- Redundância (se um cair, usa outro)
- Negociação de taxas
- Diferentes features |

---

## Resumo Final

Este marketplace de pagamentos é uma plataforma completa que:

1. **Para Vendedores**:
   - Permite receber pagamentos via PIX de forma simples
   - Oferece gestão completa de finanças
   - Disponibiliza integrações via API

2. **Para a Plataforma (Negócio)**:
   - Cobra taxas sobre transações
   - Tem controle total via painel administrativo
   - Possui mecanismos de proteção (reservas)

3. **Características Técnicas**:
   - Multi-gateway (vários provedores PIX)
   - Sistema de webhooks para notificações em tempo real
   - KYC completo para verificação de vendedores
   - Diferentes níveis de permissão administrativa
