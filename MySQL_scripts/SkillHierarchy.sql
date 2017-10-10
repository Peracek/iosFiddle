DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SkillHierarchy`(IN StartKey INT)
BEGIN
  -- prepare a hierarchy level variable 
  SET @hierlevel := 00000;

  -- prepare a variable for total rows so we know when no more rows found
  SET @lastRowCount := 0;

  -- pre-drop temp table
  DROP TABLE IF EXISTS skillHierarchy;

  -- now, create it as the first level you want... 
  -- ie: a specific top level of all "no parent" entries
  -- or parameterize the function and ask for a specific "ID".
  -- add extra column as flag for next set of ID's to load into this.
  CREATE TABLE skillHierarchy AS
  SELECT s.idskill
       , s.super_skill
       , s.title
       , 00 AS IDHierLevel
       , 00 AS AlreadyProcessed
       , 01 AS ChildNr
  FROM
    skill s
  WHERE
    s.idskill = StartKey;

  -- how many rows are we starting with at this tier level
  -- START the cycle, only IF we found rows...
  SET @lastRowCount := FOUND_ROWS();

  -- we need to have a "key" for updates to be applied against, 
  -- otherwise our UPDATE statement will nag about an unsafe update command
  CREATE INDEX MyHier_Idx1 ON skillHierarchy (IDHierLevel);


  -- NOW, keep cycling through until we get no more records
  WHILE @lastRowCount > 0
  DO

    UPDATE skillHierarchy
    SET
      AlreadyProcessed = 1
    WHERE
      IDHierLevel = @hierLevel;

    -- NOW, load in all entries found from full-set NOT already processed
    INSERT INTO skillHierarchy
    SELECT DISTINCT s.idskill
                  , s.super_skill
                  , s.title
                  , @hierLevel + 1 AS IDHierLevel
                  , 0 AS AlreadyProcessed
                  , 1
    FROM
      skillHierarchy mh
    JOIN skill s
    ON mh.idskill = s.super_skill
    WHERE
      mh.IDHierLevel = @hierLevel;

    -- preserve latest count of records accounted for from above query
    -- now, how many acrual rows DID we insert from the select query
    SET @lastRowCount := ROW_COUNT();


    -- only mark the LOWER level we just joined against as processed,
    -- and NOT the new records we just inserted
    UPDATE skillHierarchy
    SET
      AlreadyProcessed = 1
    WHERE
      IDHierLevel = @hierLevel;

    -- now, update the hierarchy level
    SET @hierLevel := @hierLevel + 1;

  END WHILE;
  
  SET SQL_SAFE_UPDATES=0;
  
  WHILE @hierLevel > 0
  DO
  
   SET @hierLevel := @hierLevel -1;
  
  update  skillHierarchy
  join (select super_skill, sum(ChildNr) as cnt from skillHierarchy group by super_skill) c on skillHierarchy.idskill = c.super_skill
  set childNr = cnt
    where IDHierLevel = @hierLevel;
  
  END WHILE;
  
  SET SQL_SAFE_UPDATES=1;

  

  SET @row_num = 0;
    SET @lewel = -1;

  -- return the final set now
  SELECT
  s.idskill,
    s.title,
    s.short_desc,
    s.icon_url,
    s.photo_url,
    s.video_url,
    s.super_skill,
    s.sort_key,
    s.background_color,
    @row_num:=IF(@lewel=mh.IDHierLevel, @row_num+@width, 0) AS col,
    @lewel:=mh.IDHierLevel as 'row',
    @width:=childNr AS width
  FROM
    skillHierarchy mh
    JOIN skill s ON mh.idskill = s.idskill
    ORDER BY mh.IDHierLevel;

-- and we can clean-up after the query of data has been selected / returned.
--    drop table if exists skillHierarchy;


END$$
DELIMITER ;
