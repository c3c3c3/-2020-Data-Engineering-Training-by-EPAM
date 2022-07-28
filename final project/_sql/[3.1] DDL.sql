CREATE DATABASE itunes;

--#CREATING USER TYPES FOR FURTHER USAGE
CREATE TYPE certificate AS ENUM ('GOLD','PLATINUM','2xPLATINUM','3xPLATINUM','4xPLATINUM','5xPLATINUM','6xPLATINUM',
'7xPLATINUM','8xPLATINUM','9xPLATINUM','BRILLIANT','OTHER');
CREATE TYPE song AS ENUM ('SOLO','COLLAB','BAND');

CREATE TABLE songs (song_id bigserial PRIMARY KEY,
					song_title TEXT NOT NULL,
					song_length INTERVAL,
					song_jenre TEXT,
					song_jenre_id TEXT,
					song_type song NOT NULL,
					song_date_of_release date,
					song_music_author TEXT,
					song_lyrics_author TEXT,
					song_producer TEXT NOT NULL,
					song_label_id int				
				   );

CREATE TABLE labels (label_id serial PRIMARY KEY,
					 label_name TEXT NOT NULL,
					 label_head TEXT,
					 parent_label TEXT);
					 
CREATE TABLE performers (performer_id bigserial PRIMARY KEY,
					  performer_name TEXT NOT NULL UNIQUE,
					  performer_gender TEXT,
					  performer_race TEXT,
					  performer_date_of_birth date,
					  performer_marital_status TEXT,
					  performer_country_id int,
					  performer_start_of_career date);
		
CREATE TABLE countries (country_id serial PRIMARY KEY,
						country_iso_code TEXT,
						country_name TEXT NOT NULL,
						country_subregion TEXT,
						country_region TEXT);

CREATE TABLE sales (sale_id bigserial PRIMARY KEY,
					performer_id int NOT NULL,
					song_id int NOT NULL,
					time_id date NOT NULL,
					number_of_position int,
					copies_sold int NOT NULL,
					certification int NOT NULL,
					price NUMERIC(4,2),
					estimate_income NUMERIC (12,2));
					
CREATE TABLE times (
	time_id date NOT NULL,
	day_name varchar(9) NULL,
	day_number_in_week int2 NULL,
	day_number_in_month int2 NULL,
	calendar_week_number int2 NULL,
	week_ending_day date NULL,
	calendar_month_number int2 NULL,
	calendar_month_desc varchar(8) NULL,
	calendar_month_id int4 NULL,
	days_in_cal_month int4 NULL,
	end_of_cal_month date NULL,
	calendar_month_name varchar(9) NULL,
	calendar_quarter_desc bpchar(7) NULL,
	calendar_quarter_id int4 NULL,
	days_in_cal_quarter int4 NULL,
	end_of_cal_quarter date NULL,
	calendar_quarter_number int2 NULL,
	calendar_half_year int2 NULL,
	end_of_cal_half_year date NULL,
	calendar_year int2 NULL,
	calendar_year_id int4 NULL,
	days_in_cal_year int4 NULL,
	end_of_cal_year date NULL,
	CONSTRAINT times_pk PRIMARY KEY (time_id)
);

CREATE TABLE promo (promo_id serial PRIMARY KEY,
					promo_title TEXT NOT NULL UNIQUE,
					estimate_audience NUMERIC (4,1) NULL,
					promo_type TEXT NULL);--awards, fest, TV show

CREATE TABLE labels (label_id serial PRIMARY KEY,
					 label_name TEXT NOT NULL,
					 parent_label_name TEXT NOT NULL,
					 head_of_label TEXT,
					 date_of_foundation date);
					
--#2. CREATING FOREIGN KEY CONSTRAINTS		
			
ALTER TABLE sales ADD CONSTRAINT sales_performer_fk FOREIGN KEY (performer_id)
REFERENCES performers(performer_id) ON UPDATE CASCADE ON DELETE RESTRICT; 

ALTER TABLE sales ADD CONSTRAINT sales_song_fk FOREIGN KEY (song_id)
REFERENCES songs(song_id) ON UPDATE CASCADE ON DELETE RESTRICT; 

ALTER TABLE sales ADD CONSTRAINT sales_times_fk FOREIGN KEY (time_id)
REFERENCES times (time_id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE performers ADD CONSTRAINT perf_cnt_fk FOREIGN KEY (performer_country_id)
REFERENCES countries (country_id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE songs ADD CONSTRAINT songs_labels_fk FOREIGN KEY (song_label_id)
REFERENCES labels (label_id) ON UPDATE CASCADE ON DELETE RESTRICT;	

--#3. CREATING CHECK CONSTRAINTS 

ALTER TABLE songs ADD CONSTRAINT song_date_check CHECK (song_date_of_release<current_timestamp);

ALTER TABLE performers ADD CONSTRAINT perf_birth_date CHECK (performer_date_of_birth<current_timestamp);

ALTER TABLE performers ADD CONSTRAINT perf_start_date CHECK (performer_start_of_career<current_timestamp);

ALTER TABLE sales ADD CONSTRAINT price_check CHECK (price>0);

--#IN CURRENT TASK, IT IS JUSTIFIED WITH THE AREA CONSIDERED HERE. BUT IF WE DECIDE TO EXPAND TO MORE POSITIONS (e.g. TOP-20),
--#THIS CONSTRAINT WILL INEVITABLY LEAD TO COLLISIONS.
ALTER TABLE sales ADD CONSTRAINT position_check CHECK (number_of_position BETWEEN 1 AND 10);