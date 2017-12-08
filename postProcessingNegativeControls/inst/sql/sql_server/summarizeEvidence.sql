IF OBJECT_ID('@storeData', 'U') IS NOT NULL DROP TABLE @storeData;

SELECT u.CONCEPT_ID AS OUTCOME_OF_INTEREST_CONCEPT_ID,
	u.CONCEPT_NAME AS OUTCOME_OF_INTEREST_CONCEPT_NAME,
	u.PERSON_COUNT_RC, u.PERSON_COUNT_DC,
	COUNT(DISTINCT descendant.UNIQUE_IDENTIFIER) AS DESCENDANT_PMID_COUNT,
	COUNT(DISTINCT exact.UNIQUE_IDENTIFIER) AS EXACT_PMID_COUNT,
	COUNT(DISTINCT parent.UNIQUE_IDENTIFIER) AS PARENT_PMID_COUNT,
	COUNT(DISTINCT ancestor.UNIQUE_IDENTIFIER) AS ANCESTOR_PMID_COUNT,
	MAX(CASE WHEN i.CONCEPT_ID IS NULL THEN 0 ELSE 1 END) AS INDICATION,
	{@outcomeOfInterest == 'condition'}?{MAX(CASE WHEN tb.CONCEPT_ID IS NULL THEN 0 ELSE 1 END) AS TOO_BROAD,}
	MAX(CASE WHEN di.CONCEPT_ID IS NULL THEN 0 ELSE 1 END) AS DRUG_INDUCED,
	{@outcomeOfInterest == 'condition'}?{MAX(CASE WHEN p.CONCEPT_ID IS NULL THEN 0 ELSE 1 END) AS PREGNANCY,}
	MAX(CASE WHEN s.CONCEPT_ID IS NULL THEN 0 ELSE 1 END) AS SPLICER,
	MAX(CASE WHEN f.CONCEPT_ID IS NULL THEN 0 ELSE 1 END) AS FAERS,
	MAX(CASE WHEN ue.CONCEPT_ID IS NULL THEN 0 ELSE 1 END) AS USER_EXCLUDED,
	MAX(CASE WHEN ui.CONCEPT_ID IS NULL THEN 0 ELSE 1 END) AS USER_INCLUDED
INTO @storeData
FROM @conceptUniverseData u
	LEFT OUTER JOIN @adeSummaryData descendant
		ON descendant.OUTCOME_OF_INTEREST_CONCEPT_ID = u.CONCEPT_ID
		AND descendant.MAPPING_TYPE = 'DESCENDANT'
	LEFT OUTER JOIN @adeSummaryData exact
		ON exact.OUTCOME_OF_INTEREST_CONCEPT_ID = u.CONCEPT_ID
		AND exact.MAPPING_TYPE = 'EXACT'
	LEFT OUTER JOIN @adeSummaryData parent
		ON parent.OUTCOME_OF_INTEREST_CONCEPT_ID = u.CONCEPT_ID
		AND parent.MAPPING_TYPE = 'PARENT'
	LEFT OUTER JOIN @adeSummaryData ancestor
		ON ancestor.OUTCOME_OF_INTEREST_CONCEPT_ID = u.CONCEPT_ID
		AND ancestor.MAPPING_TYPE = 'ANCESTOR'
	LEFT OUTER JOIN @indicationData i
		ON i.CONCEPT_ID = u.CONCEPT_ID

	{@outcomeOfInterest == 'condition'}?{
  	LEFT OUTER JOIN @broadConceptsData  tb
  		ON tb.CONCEPT_ID = u.CONCEPT_ID
	}

	LEFT OUTER JOIN @drugInducedConditionsData di
		ON di.CONCEPT_ID = u.CONCEPT_ID

	{@outcomeOfInterest == 'condition'}?{
  	LEFT OUTER JOIN @pregnancyConditionData p
  		ON p.CONCEPT_ID = u.CONCEPT_ID
  }

	LEFT OUTER JOIN @splicerConditionData s
		ON s.CONCEPT_ID = u.CONCEPT_ID
	LEFT OUTER JOIN @faersConceptsData f
		ON f.CONCEPT_ID = u.CONCEPT_ID
	LEFT OUTER JOIN @conceptsToExclude ue
		ON ue.CONCEPT_ID = u.CONCEPT_ID
	LEFT OUTER JOIN @conceptsToInclude ui
		ON ui.CONCEPT_ID = u.CONCEPT_ID
GROUP BY u.CONCEPT_ID, u.CONCEPT_NAME, u.PERSON_COUNT_RC, u.PERSON_COUNT_DC
ORDER BY PERSON_COUNT_DC DESC, PERSON_COUNT_RC;

CREATE INDEX IDX_SUMMARIZE_EVIDENCE ON @storeData (OUTCOME_OF_INTEREST_CONCEPT_ID);

