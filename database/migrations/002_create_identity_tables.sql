CREATE TYPE user_acc_status AS ENUM ('active', 'suspended', 'disabled', 'deleted');

CREATE TYPE invitation_status AS ENUM (
    'pending',
    'accepted',
    'rejected',
    'revoked',
    'expired'
);

CREATE TYPE membership_status AS ENUM ('pending', 'active', 'revoked', 'suspended');

CREATE TABLE
    organizations (
        id UUID PRIMARY KEY DEFAULT uuidv7(),
        name VARCHAR(100) NOT NULL,
        created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
        default_role_id INT
    );

CREATE TABLE
    users (
        id UUID PRIMARY KEY DEFAULT uuidv7(),
        first_name VARCHAR(50) NOT NULL,
        last_name VARCHAR(50) NOT NULL,
        email VARCHAR(255) NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        status user_acc_status NOT NULL DEFAULT 'active',
        created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
        last_login TIMESTAMPTZ
    );

CREATE UNIQUE INDEX idx_uq_lower_email ON users (LOWER(email));

CREATE TABLE
    memberships (
        org_id UUID REFERENCES organizations (id) NOT NULL,
        user_id UUID REFERENCES users (id) NOT NULL,
        created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
        status membership_status NOT NULL DEFAULT 'active',
        PRIMARY KEY (org_id, user_id)
    );

CREATE TABLE
    roles (
        id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        title VARCHAR(100) NOT NULL,
        created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
        org_id UUID NOT NULL,
        UNIQUE (org_id, title),
        UNIQUE (org_id, id),
        CONSTRAINT fk_roles_org FOREIGN KEY (org_id) REFERENCES organizations (id) ON DELETE CASCADE ON UPDATE CASCADE
    );

CREATE TABLE
    permissions (
        id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        title VARCHAR(100) NOT NULL,
        key VARCHAR(100) NOT NULL,
        org_id UUID NOT NULL,
        created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
        UNIQUE (org_id, title),
        UNIQUE (org_id, id),
        UNIQUE (org_id, key),
        CONSTRAINT fk_permissions_org FOREIGN KEY (org_id) REFERENCES organizations (id) ON DELETE CASCADE ON UPDATE CASCADE
    );

create table
    membership_roles (
        org_id UUID NOT NULL,
        user_id UUID NOT NULL,
        role_id INT NOT NULL,
        FOREIGN KEY (org_id, role_id) REFERENCES roles (org_id, id),
        FOREIGN KEY (org_id, user_id) REFERENCES memberships (org_id, user_id),
        PRIMARY KEY (org_id, user_id, role_id)
    );

CREATE TABLE
    role_permissions (
        role_id INT NOT NULL,
        permission_id INT NOT NULL,
        org_id UUID NOT NULL,
        FOREIGN KEY (org_id, permission_id) REFERENCES permissions (org_id, id),
        FOREIGN KEY (org_id, role_id) REFERENCES roles (org_id, id),
        PRIMARY KEY (role_id, permission_id)
    );

CREATE TABLE
    teams (
        id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        org_id UUID NOT NULL,
        created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
        UNIQUE (name, org_id),
        UNIQUE (id, org_id),
        CONSTRAINT fk_teams_org
            FOREIGN KEY (org_id) REFERENCES organizations (id) ON DELETE CASCADE ON UPDATE CASCADE
    );

CREATE TABLE
    team_members (
        org_id UUID NOT NULL,
        user_id UUID NOT NULL,
        team_id INT NOT NULL,
        CONSTRAINT fk_team_membership FOREIGN KEY (org_id, user_id) REFERENCES memberships (org_id, user_id) ON DELETE CASCADE ON UPDATE CASCADE,
        CONSTRAINT fk_team_org FOREIGN KEY (team_id, org_id) REFERENCES teams (id, org_id) ON DELETE CASCADE ON UPDATE CASCADE,
        PRIMARY KEY (user_id, org_id, team_id)
    );

CREATE TABLE
    sessions (
        id UUID PRIMARY KEY DEFAULT uuidv7 (),
        token_hash TEXT NOT NULL UNIQUE,
        created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
        expires_at TIMESTAMPTZ NOT NULL,
        refreshed_at TIMESTAMPTZ,
        revoked_at TIMESTAMPTZ,
        user_id UUID NOT NULL,
        metadata JSONB,
        CONSTRAINT fk_sessions_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
    );

CREATE TABLE
    invitations (
        id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        org_id UUID NOT NULL,
        email VARCHAR(255) NOT NULL,
        status invitation_status NOT NULL DEFAULT 'pending',
        expires_at TIMESTAMPTZ NOT NULL,
        created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
        accepted_at TIMESTAMPTZ,
        invited_by UUID NOT NULL,
        invited_user UUID,
        UNIQUE (id, org_id),
        FOREIGN KEY (org_id, invited_by) REFERENCES memberships (org_id, user_id),
        FOREIGN KEY (org_id, invited_user) REFERENCES memberships (org_id, user_id),
        CONSTRAINT fk_invitations_org 
            FOREIGN KEY (org_id) 
                REFERENCES organizations (id) 
                ON DELETE CASCADE 
                ON UPDATE CASCADE
    );

CREATE TABLE
    invitation_roles (
        role_id INT NOT NULL,
        invitation_id INT NOT NULL,
        org_id UUID NOT NULL,
        FOREIGN KEY (invitation_id, org_id) REFERENCES invitations (id, org_id),
        FOREIGN KEY (role_id, org_id) REFERENCES roles (id, org_id),
        PRIMARY KEY (invitation_id, role_id)
    );

ALTER TABLE organizations 
    ADD CONSTRAINT fk_org_default_role FOREIGN KEY (id, default_role_id) 
    REFERENCES roles (org_id, id) 
    ON DELETE NO ACTION;

CREATE UNIQUE INDEX idx_uq_invitation_pending_email_org ON invitations (org_id, LOWER(email))
WHERE status = 'pending';

GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA public TO readwrite;

GRANT USAGE, SELECT, UPDATE
ON ALL SEQUENCES IN SCHEMA public TO readwrite;

GRANT SELECT
ON ALL TABLES IN SCHEMA public TO readonly;
