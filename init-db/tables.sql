
CREATE TYPE user_acc_status AS ENUM("active", "suspended", "disabled", "deleted")
CREATE TYPE invitation_status AS ENUM("pending", "accepted", "rejected", "revoked", "expired")
CREATE TYPE membership_status AS ENUM("pending", "active", "revoked", "suspended")

CREATE TABLE organizations(
    id uuid PRIMARY KEY uuidv7()
    name VARCHAR(100) NOT NULL
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
    default_role_id INT 

    CONSTRAINT fk_org_default_role
    FOREIGN KEY (default_role_id)
        REFERENCES roles(id)
            ON UPDATE CASCADE
)

CREATE TABLE users(
    id uuid PRIMARY KEY DEFAULT uuidv7() 
    first_name VARCHAR(50) NOT NULL
    last_name VARCHAR(50) NOT NULL
    email VARCHAR(255) UNIQUE NOT NULL
    password VARCHAR(255) NOT NULL
    status user_acc_status DEFAULT "active"
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
    last_login TIMESTAMPTZ
)

CREATE TABLE memberships (
    org_id uuid REFERENCES organizations(id)
    user_id uuid REFERENCES users(id)
    role_id INT REFERENCES roles(id)

    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
    status membership_status DEFAULT 'active'

    PRIMARY KEY (org_id, user_id, role_id)
)

/* CREATE TABLE user_roles(
    user_id uuid REFERENCES users(id)
    role_id INT REFERENCES roles(id)
    assigned_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP

    PRIMARY KEY (user_id, role_id)
)
 */

CREATE TABLE teams (
    id INT SERIAL PRIMARY KEY
    org_id uuid NOT NULL
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP

    CONSTRAINT fk_teams_org
    FOREIGN KEY (org_id)
        REFERENCES organizations(id)
            ON DELETE CASCADE
            ON UPDATE CASCADE
)

CREATE TABLE team_members (
    membership_id
    team_id INT

    CONSTRAINT fk_team_members_user
    FOREIGN KEY()
        REFERENCES memberships(id)
            ON DELETE CASCADE
            ON UPDATE CASCADE

    CONSTRAINT fk_team_members_team
        FOREIGN KEY(team_id)
            REFERENCES teams(id)
                ON DELETE CASCADE
                ON UPDATE CASCADE

    PRIMARY KEY (user_id, team_id)        
)

CREATE INDEX idx_users_email ON users(email)

CREATE TABLE sessions (
    id uuid PRIMARY KEY DEFAULT uuidv7() 
    token_hash TEXT NOT NULL
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP 
    expires_at TIMESTAMPTZ NOT NULL
    refreshed_at TIMESTAMPTZ 
    revoked_at TIMESTAMPTZ
    replaced_by uuid
    user_id uuid 
    metadata JSONB

    CONSTRAINT fk_sessions_user
    FOREIGN KEY (user_id) 
        REFERENCES users(id) 
            ON DELETE CASCADE 
)

CREATE TABLE roles (
    id INT SERIAL PRIMARY KEY
    title VARCHAR(100) NOT NULL
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
    org_id uuid

    CONSTRAINT fk_roles_org
    FOREIGN KEY (org_id)
        REFERENCES organizations(id)
            ON DELETE CASCADE
            ON UPDATE CASCADE
)

CREATE TABLE permissions (
    id INT SERIAL PRIMARY KEY
    title VARCHAR(100) NOT NULL
    org_id uuid
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP

    CONSTRAINT fk_permissions_org
    FOREIGN KEY (org_id)
        REFERENCES organizations(id)
            ON DELETE CASCADE
            ON UPDATE CASCADE
)

CREATE TABLE role_permissions(
    role_id INT REFERENCES roles(id) ON DELETE CASCADE
    permission_id INT REFERENCES permissions(id) ON DELETE CASCADE

    PRIMARY KEY (role_id, permission_id)
)

CREATE TABLE invitations(
    id INT SERIAL PRIMARY KEY
    org_id uuid
    invited_user_id uuid
    roles INT[]
    status invitation_status
    expires_at TIMESTAMPTZ
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
    accepted_at TIMESTAMPTZ

    CONSTRAINT fk_invitations_org
    FOREIGN KEY(org_id)
        REFERENCES organizations(id)
            ON DELETE CASCADE
            ON UPDATE CASCADE

    CONSTRAINT fk_invitations_user
    FOREIGN KEY(invited_user_id)
        REFERENCES users(id)
            ON DELETE CASCADE
            ON UPDATE CASCADE

    CONSTRAINT fk_invitations_role
    FOREIGN KEY(roles)
        REFERENCES roles(id)
            ON DELETE CASCADE
            ON UPDATE CASCADE
)

CREATE TABLE documents (
    id uuid PRIMARY KEY DEFAULT uuidv7() 
    title TEXT NOT NULL
    file_url TEXT NOT NULL
    metadata JSONB 
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP 
    viewed_by uuid[]
)

CREATE TABLE flights (
    id uuid PRIMARY KEY DEFAULT uuidv7() 
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP 
    arrived_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP 
    departed_at TIMESTAMP
    destination ENUM
    provenance ENUM
    controlled_by uuid DEFAULT '00000000-0000-0000-0000-000000000001'

    CONSTRAINT fk_flight_user
    FOREIGN KEY (controlled_by)
        REFERENCES users(id)
            ON DELETE SET DEFAULT
)

CREATE TABLE audit_logs(
    id uuid gen_uuidv7 PRIMARY KEY
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP 
    resource_id uuid
    actions ENUM 
)


