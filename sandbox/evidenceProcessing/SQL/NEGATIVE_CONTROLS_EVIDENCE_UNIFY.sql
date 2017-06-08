IF OBJECT_ID('@tableName','U') IS NOT NULL
DROP TABLE @tableName;

CREATE TABLE @tableName (
  ID INT IDENTITY(1,1) PRIMARY KEY,
	CONCEPT_ID_1	INT,
	CONCEPT_ID_2	INT,
	SOURCE_ID	VARCHAR(20),
	EVIDENCE_TYPE VARCHAR(255),
	RELATIONSHIP_ID	VARCHAR(20),
	STATISTIC_VALUE FLOAT,
	STATISTIC_VALUE_TYPE VARCHAR(20),
	UNIQUE_IDENTIFIER	VARCHAR(50),
	UNIQUE_IDENTIFIER_TYPE	VARCHAR(50),
	COUNT_HOW VARCHAR(255)
);

INSERT INTO @tableName (CONCEPT_ID_1, CONCEPT_ID_2, SOURCE_ID, EVIDENCE_TYPE,
  RELATIONSHIP_ID, STATISTIC_VALUE, STATISTIC_VALUE_TYPE, UNIQUE_IDENTIFIER,
  UNIQUE_IDENTIFIER_TYPE, COUNT_HOW)

/*MEDLINE_AVILLACH_EVIDENCE*/
SELECT DISTINCT
	CONCEPT_ID_1, CONCEPT_ID_2,
	SOURCE_ID,
	CASE
		WHEN PUBLICATION_TYPE IN ('Clinical Trial', 'Controlled Clinical Trial', 'Clinical Trial, Phase I', 'Clinical Trial, Phase II', 'Clinical Trial, Phase III','Clinical Trial, Phase IV', 'Randomized Controlled Trial','Multicenter Study') THEN 'Clinical Trial'
		ELSE 'PUBLICATION_TYPE'
	END AS EVIDENCE_TYPE,
	RELATIONSHIP_ID,
	1 AS STATISTIC_VALUE,
	'COUNT' AS STATISTIC_VALUE_TYPE,
	UNIQUE_IDENTIFIER,
	UNIQUE_IDENTIFIER_TYPE,
	'COUNT DISTINCT UNIQUE_IDENTIFIER' AS COUNT_HOW
FROM MEDLINE_AVILLACH_EVIDENCE

UNION

/*AEOLUS_EVIDENCE*/
SELECT DISTINCT
	CONCEPT_ID_1, CONCEPT_ID_2,
	SOURCE_ID,
	'COUNT' AS EVIDENCE_TYPE,
	RELATIONSHIP_ID,
	CASE_COUNT AS STATISTIC_VALUE,
	'CASE COUNT' AS STATISTIC_VALUE_TYPE,
	UNIQUE_IDENTIFIER,
	UNIQUE_IDENTIFIER_TYPE,
	'SUM COUNTS' AS COUNT_HOU
FROM AEOLUS_EVIDENCE
UNION
SELECT CONCEPT_ID_1, CONCEPT_ID_2,
	SOURCE_ID,
	'PRR' AS EVIDENCE_TYPE,
	RELATIONSHIP_ID,
	PRR AS STATISTIC_VALUE,
	'PRR' AS STATISTIC_VALUE_TYPE,
	UNIQUE_IDENTIFIER,
	UNIQUE_IDENTIFIER_TYPE,
	'GEOMETRIC MEAN OF PRR' AS COUNT_HOU
FROM AEOLUS_EVIDENCE
UNION
SELECT CONCEPT_ID_1, CONCEPT_ID_2,
	SOURCE_ID,
	'ROR' AS EVIDENCE_TYPE,
	RELATIONSHIP_ID,
	PRR AS STATISTIC_VALUE,
	'ROR' AS STATISTIC_VALUE_TYPE,
	UNIQUE_IDENTIFIER,
	UNIQUE_IDENTIFIER_TYPE,
	'GEOMETRIC MEAN OF ROR' AS COUNT_HOU
FROM AEOLUS_EVIDENCE;

CREATE INDEX IDX_UNIQUE_@tableName_IDENTIFIER_DRUG_CONCEPT_ID_1_DRUG_CONCEPT_ID_2 ON @tableName (UNIQUE_IDENTIFIER, CONCEPT_ID_1, CONCEPT_ID_2);

