

CREATE TABLE documents (
    id UUID PRIMARY KEY DEFAULT uuidv7() 
    title TEXT NOT NULL
    file_url TEXT NOT NULL
    metadata JSONB 
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP 
    viewed_by UUID[]
)

CREATE TABLE flights (
    id UUID PRIMARY KEY DEFAULT uuidv7() 
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP 
    arrived_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP 
    departed_at TIMESTAMP
    destination ENUM
    provenance ENUM
    controlled_by UUID DEFAULT '00000000-0000-0000-0000-000000000001'

    CONSTRAINT fk_flight_user
    FOREIGN KEY (controlled_by)
        REFERENCES users(id)
            ON DELETE SET DEFAULT
)

CREATE TABLE audit_logs(
    id UUID gen_uuidv7 PRIMARY KEY
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP 
    resource_id UUID
    actions ENUM 
)


