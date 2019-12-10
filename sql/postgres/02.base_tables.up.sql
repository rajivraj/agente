CREATE TABLE IF NOT EXISTS ra_users (
    id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    username varchar(64) not null,
    password varchar(200) not null,
    email    varchar(64),
    is_active boolean default true,
    inserted_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (CURRENT_TIMESTAMP at time zone 'utc'),
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (CURRENT_TIMESTAMP at time zone 'utc')
);

CREATE UNIQUE INDEX IF NOT EXISTS ra_users_username_unique_index ON ra_users USING btree (username);
CREATE UNIQUE INDEX IF NOT EXISTS ra_users_email_unique_index ON ra_users USING btree (email);

CREATE TRIGGER ts_ra_users before INSERT or UPDATE ON ra_users
    FOR EACH ROW EXECUTE FUNCTION timestamps_gen();


CREATE TYPE job AS ENUM ('new_release', 'start', 'restart', 'shutdown', 'other');

CREATE TABLE IF NOT EXISTS ra_jobs (
    id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    source_user_id bigint null,
    inserted_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (CURRENT_TIMESTAMP at time zone 'utc'),

    CONSTRAINT fk_ra_jobs_source_user_id foreign key (source_user_id) references ra_users(id) on update cascade on delete set null
);

CREATE INDEX ra_jobs_source_user_id_index ON ra_jobs USING btree(source_user_id);

CREATE TABLE IF NOT EXISTS ra_job_details (
    id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    job_id bigint not null,
    source_user_id bigint null,

    name varchar(200) not null,
    type job default 'new_release',
    detail text null,
    before boolean default false,
    after boolean default false,

    script_file varchar(200) null,
    script text null,

    inserted_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (CURRENT_TIMESTAMP at time zone 'utc'),

    CONSTRAINT fk_ra_job_details_job_id foreign key (job_id) references ra_jobs(id) on update cascade on delete cascade,
    CONSTRAINT fk_ra_job_details_source_user_id foreign key (source_user_id) references ra_users(id) on update cascade on delete set null
);

CREATE INDEX ra_job_details_job_id_index ON ra_job_details USING btree(job_id);
CREATE INDEX ra_job_details_source_user_id_index ON ra_job_details USING btree(source_user_id);

CREATE TABLE IF NOT EXISTS ra_job_logs (
    id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    job_id bigint not null,
    data jsonb null,
    state boolean default false,
    inserted_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (CURRENT_TIMESTAMP at time zone 'utc'),

    CONSTRAINT fk_ra_job_logs_job_id foreign key (job_id) references ra_jobs(id) on update cascade on delete cascade
);

CREATE INDEX ra_job_logs_job_id_index ON ra_job_logs USING btree(job_id);
CREATE INDEX ra_job_logs_inserted_at_index ON ra_job_logs USING btree(inserted_at DESC);
