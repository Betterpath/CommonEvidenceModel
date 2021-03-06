{@outcomeOfInterest == 'condition'}?{
  SELECT c.CONCEPT_ID, c.CONCEPT_NAME,
  	SUM(u.PERSON_COUNT_ESTIMATE_RC) AS PERSON_COUNT_RC,
    SUM(u.PERSON_COUNT_ESTIMATE_DC) AS PERSON_COUNT_DC
  FROM @sourceData u
  	JOIN @vocabulary.CONCEPT c
  		ON c.CONCEPT_ID = u.CONDITION_CONCEPT_ID
    	AND c.DOMAIN_ID = 'Condition'
  WHERE DRUG_CONCEPT_ID IN (
  	SELECT DESCENDANT_CONCEPT_ID FROM @vocabulary.CONCEPT_ANCESTOR WHERE ANCESTOR_CONCEPT_ID IN (@conceptsOfInterest)
  )
  GROUP BY c.CONCEPT_ID, c.CONCEPT_NAME
  HAVING SUM(u.PERSON_COUNT_ESTIMATE_RC) > 10
}
{@outcomeOfInterest == 'drug'}?{
  SELECT c.CONCEPT_ID, c.CONCEPT_NAME,
  	SUM(u.PERSON_COUNT_ESTIMATE_RC) AS PERSON_COUNT_RC,
  	SUM(u.PERSON_COUNT_ESTIMATE_DC) AS PERSON_COUNT_DC
  FROM @sourceData u
  	JOIN @vocabulary.CONCEPT c
  		ON c.CONCEPT_ID = u.DRUG_CONCEPT_ID
  		AND c.DOMAIN_ID = 'Drug'
  WHERE CONDITION_CONCEPT_ID IN (
  	SELECT DESCENDANT_CONCEPT_ID FROM @vocabulary.CONCEPT_ANCESTOR WHERE ANCESTOR_CONCEPT_ID IN (@conceptsOfInterest)
  )
  GROUP BY c.CONCEPT_ID, c.CONCEPT_NAME
  HAVING SUM(u.PERSON_COUNT_ESTIMATE_RC) > 10
}


