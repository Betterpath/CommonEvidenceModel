IF OBJECT_ID('@tableName', 'U') IS NOT NULL DROP TABLE @tableName;

WITH CTE_VOCAB_PULL AS (
	SELECT *
	FROM @sourceToConceptMap
	WHERE SOURCE_VOCABULARY_ID = 'MESH_TO_STANDARD'
)
SELECT ID,
      SOURCE_ID,
      SOURCE_CODE_1,
      SOURCE_CODE_TYPE_1,
      SOURCE_CODE_NAME_1,
      CASE WHEN v1.TARGET_CONCEPT_ID IS NULL THEN 0 ELSE v1.TARGET_CONCEPT_ID END AS CONCEPT_ID_1,
      RELATIONSHIP_ID,
      SOURCE_CODE_2,
      SOURCE_CODE_TYPE_2,
      SOURCE_CODE_NAME_2,
      CASE WHEN v2.TARGET_CONCEPT_ID IS NULL THEN 0 ELSE v2.TARGET_CONCEPT_ID END AS CONCEPT_ID_2,
      UNIQUE_IDENTIFIER,
      UNIQUE_IDENTIFIER_TYPE,
      ARTICLE_TITLE,
      ABSTRACT,
      ABSTRACT_ORDER,
      JOURNAL,
      ISSN,
      PUBLICATION_YEAR,
      PUBLICATION_TYPE
INTO @tableName
FROM @sourceTableName c
	LEFT OUTER JOIN CTE_VOCAB_PULL v1
		ON v1.SOURCE_CODE = c.SOURCE_CODE_1
	LEFT OUTER JOIN CTE_VOCAB_PULL v2
		ON v2.SOURCE_CODE = c.SOURCE_CODE_2;

CREATE INDEX IDX_@tableName_CONCEPT_ID_1_CONCEPT_ID_2 ON @tableName (CONCEPT_ID_1, CONCEPT_ID_2);