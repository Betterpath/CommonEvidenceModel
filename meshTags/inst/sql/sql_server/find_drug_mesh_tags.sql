WITH CTE_FIND_DRUGS AS (
	SELECT DRUG_CONCEPT_ID AS INGREDIENT_CONCEPT_ID,
	  c.CONCEPT_NAME AS INGREDIENT_CONCEPT_NAME,
		MAX(c2.CONCEPT_ID) AS MESH_CONCEPT_ID,
		COUNT(DISTINCT PERSON_ID) AS RECORD_COUNT,
		'DISTINCT PERSON' AS RECORD_TYPE
	FROM DRUG_ERA de
		JOIN CONCEPT c
			ON c.CONCEPT_ID = de.DRUG_CONCEPT_ID
		JOIN CONCEPT_RELATIONSHIP cr
			ON cr.CONCEPT_ID_1 = c.CONCEPT_ID
		JOIN CONCEPT c2
			ON c2.CONCEPT_ID = cr.CONCEPT_ID_2
			AND c2.VOCABULARY_ID = 'MeSH'
			AND c2.INVALID_REASON IS NULL
	WHERE YEAR(GETDATE())-2 BETWEEN YEAR(DRUG_ERA_START_DATE) AND YEAR(DRUG_ERA_END_DATE) /*year where you reliably have full year*/
	GROUP BY DRUG_CONCEPT_ID, c.CONCEPT_NAME
	HAVING COUNT(DISTINCT PERSON_ID) >= 10
)
SELECT 'DRUG' AS MESH_TYPE, c1.CONCEPT_CODE AS MESH_SOURCE_CODE,
  c1.CONCEPT_NAME AS MESH_SOURCE_NAME, d.RECORD_COUNT, d.RECORD_TYPE
FROM CTE_FIND_DRUGS d
	JOIN CONCEPT c1
		ON c1.CONCEPT_ID = d.MESH_CONCEPT_ID
ORDER BY RECORD_COUNT DESC;
