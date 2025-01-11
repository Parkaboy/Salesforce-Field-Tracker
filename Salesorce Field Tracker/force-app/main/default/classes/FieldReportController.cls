/*************************************************************************************************************
 * @name			FieldReportController
 * @author			Martín De León
 * @created			27 / 12 / 2024
 * @description		Description of your code
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2024-12-27		Martín De León			Changes desription
 *
 **************************************************************************************************************/
public with sharing class FieldReportController {
    private static final String CUSTOM_OBJECT_SUFIX = 'c';
    private static final String HISTORY_OBJECT_SUFIX = 'History';

    @AuraEnabled(cacheable=true)
    public static List<ObjectInfo> getObjectList() {

        List<ObjectInfo> lstSObjects = new List<ObjectInfo>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();

        for (String objName : schemaMap.keySet()) {

            Schema.SObjectType objType = schemaMap.get(objName);
            Schema.DescribeSObjectResult describeResult = objType.getDescribe();

            if (describeResult.isSearchable() ) {
                ObjectInfo objInfo = new ObjectInfo();
                objInfo.label = describeResult.getLabel();
                objInfo.name = objName;
                lstSObjects.add(objInfo);            
            }
        }

        return lstSObjects;
    }

    /*********************************************************************************************************
     * @name			getFields
     * @author			Martín De León
     * @created			27 / 12 / 2024
     * @description		Description of your code
     * @param			String param : Explanation
     * @return			Explanation of the return value
     **********************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<Object> getFields(String sObjectName, Integer years) {
        
        String query = 'SELECT Id, Field, OldValue, NewValue, CreatedDate FROM ';

        query = query + getHistorySObject(sObjectName);

        query = query + ' WHERE CreatedDate IN ( SELECT MAX(CreatedDate) FROM ' + sObjectName + ' GROUP BY Field )';

        if (years != null && years > 0) {
            Date filter = System.today().addYears(-years);

            query = query + ' AND CreatedDate < :' + filter;
        }

        query = query + ' ORDER BY Field ASC, CreatedDate ASC';

        return queryHistoryFields(query);
    }


    /*********************************************************************************************************
     * @name			queryHistoryFields
     * @author			Martín De León
     * @created			27 / 12 / 2024
     * @description		Description of your code
     * @param			String param : Explanation
     * @return			Explanation of the return value
     **********************************************************************************************************/    
    private static List<Object> queryHistoryFields(String query) {

        List<Object> lstResult = new List<Object>();

        try {
            lstResult = Database.query(query);
        } catch (QueryException ex) {
            System.debug(logginglevel.ERROR, ex.getStackTraceString());
        }

        return lstResult;
    }

    /*********************************************************************************************************
     * @name			getFields
     * @author			Martín De León
     * @created			27 / 12 / 2024
     * @description		Description of your code
     * @param			String param : Explanation
     * @return			Explanation of the return value
     **********************************************************************************************************/
    private static String getHistorySObject(String sObjectName) {
        String historySObject = sObjectName;

        if (isCustomObject(sObjectName)) {
            historySObject = sObjectName.remove(CUSTOM_OBJECT_SUFIX);
        }

        return historySObject + HISTORY_OBJECT_SUFIX;
    }


        /*********************************************************************************************************
     * @name			getFields
     * @author			Martín De León
     * @created			27 / 12 / 2024
     * @description		Description of your code
     * @param			String param : Explanation
     * @return			Explanation of the return value
     **********************************************************************************************************/
    private static Boolean isCustomObject(String sObjectName) {

        Boolean isCustomObject = false;

        if (sObjectName.endsWithIgnoreCase(CUSTOM_OBJECT_SUFIX)) {
            isCustomObject = true;
        }

        return isCustomObject;
    }


    /*************************************************************************************************************
     * @name			ObjectInfo
     * @author			Martín De León
     * @created			01 / 01 / 2025
     * @description		Description of your code
     *
     * Changes (version)
     * -----------------------------------------------------------------------------------------------------------
     * 				No.		Date			Author					Description
     * 				----	------------	--------------------	----------------------------------------------
     * @version		1.0		2025-01-01		Martín De León			Changes desription
     *
    **************************************************************************************************************/
    private class ObjectInfo {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String name { get; set; }
    }
}
