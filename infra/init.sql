-- Baseado na Documentação: Entidades Principais

-- 1. Usuários (Vendedores e Admins)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('SELLER', 'ADMIN', 'SUPER_ADMIN')), -- [cite: 17]
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Empresas (Dados do Vendedor) [cite: 80]
CREATE TABLE enterprises (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    document_number VARCHAR(20) UNIQUE NOT NULL, -- CNPJ/CPF
    legal_name VARCHAR(255) NOT NULL, -- Razão Social
    trade_name VARCHAR(255), -- Nome Fantasia
    status VARCHAR(50) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED', 'BLOCKED')), -- KYC Status
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Carteira do Vendedor (Saldos e Reservas) [cite: 25, 54]
CREATE TABLE seller_balances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    enterprise_id UUID REFERENCES enterprises(id) UNIQUE,
    available_amount DECIMAL(15, 2) DEFAULT 0.00, -- Disponível para saque
    reserved_amount DECIMAL(15, 2) DEFAULT 0.00,  -- Retido por segurança (Chargeback)
    pending_amount DECIMAL(15, 2) DEFAULT 0.00,   -- Transações em processamento
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Links de Pagamento [cite: 24]
CREATE TABLE payment_links (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    enterprise_id UUID REFERENCES enterprises(id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    amount DECIMAL(10, 2), -- Pode ser nulo se o cliente definir o valor
    unique_slug VARCHAR(100) UNIQUE NOT NULL, -- Ex: pay.exemplo.com/abc123
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. Transações [cite: 26]
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    enterprise_id UUID REFERENCES enterprises(id),
    payment_link_id UUID REFERENCES payment_links(id),
    
    -- Valores calculados [cite: 45]
    gross_amount DECIMAL(10, 2) NOT NULL, -- Valor Bruto
    fee_amount DECIMAL(10, 2) NOT NULL,   -- Taxas da Plataforma
    net_amount DECIMAL(10, 2) NOT NULL,   -- Valor Líquido
    
    payment_method VARCHAR(50) DEFAULT 'PIX',
    status VARCHAR(50) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'PAID', 'FAILED', 'REFUNDED')),
    customer_email VARCHAR(255), -- Dados simples do cliente [cite: 27]
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);