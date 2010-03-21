select 1 from-- Skapa en ny tabell med de endast de språkkoder vi accepterar
CREATE TABLE public.languages (
    language_code char(2) PRIMARY KEY
);
INSERT INTO public.languages VALUES ('sv'),('de'),('da'),('no'),('fi');
COMMENT ON COLUMN public.languages.language_code IS 'Codes according to ISO 639';
GRANT SELECT ON public.languages TO GROUP readonly;
GRANT ALL    ON public.languages TO GROUP readwrite;

-- Lägg till en ny column i color_description som hanterar language_code instället för
-- locale som idag.
--   1. Lägg till kolumnen.
--   2. Fyll den med data från locale kolumnen.
--   3. Ändra så att columnen inte får vara tom
--   4. Lägg till constraint mot tidigare skapade tabellen languages.
--   5. Sätt kommentar på locale kolumnen om att den inte bör användas.
ALTER TABLE products.color_description ADD COLUMN language_code char(2);
UPDATE products.color_description
SET language_code = (CASE WHEN locale like 'ty%'
                        THEN 'de'
                        ELSE SUBSTRING(locale FROM 1 FOR 2) END);
ALTER TABLE products.color_description ALTER COLUMN language_code SET NOT NULL;
ALTER TABLE products.color_description
    ADD CONSTRAINT products_color_description_lang_ref
    FOREIGN KEY (language_code) REFERENCES public.languages(language_code);
COMMENT ON COLUMN products.color_description.locale
IS '<¡> PAHSE OUT, use language_code instead';



-- Lägg till en ny column i frame_description som hanterar language_code instället för
-- locale som idag.
--   1. Lägg till kolumnen.
--   2. Fyll den med data från locale kolumnen.
--   3. Ändra så att columnen inte får vara tom
--   4. Lägg till constraint mot tidigare skapade tabellen languages.
--   5. Sätt kommentar på locale kolumnen om att den inte bör användas.
ALTER TABLE products.frame_description ADD COLUMN language_code char(2);
UPDATE products.frame_description
SET language_code = (CASE WHEN locale like 'ty%'
                        THEN 'de'
                        ELSE SUBSTRING(locale FROM 1 FOR 2) END);
ALTER TABLE products.frame_description ALTER COLUMN language_code SET NOT NULL;
ALTER TABLE products.frame_description
    ADD CONSTRAINT products_frame_description_lang_ref
    FOREIGN KEY (language_code) REFERENCES public.languages(language_code);
COMMENT ON COLUMN products.frame_description.locale
IS '<¡> PAHSE OUT, use language_code instead';
