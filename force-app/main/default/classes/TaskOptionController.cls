public with sharing class TaskOptionController {

    @AuraEnabled(cacheable=true)
    public static Map<String, List<String>> getTaskPicklistOptions() {
        Map<String, List<String>> result = new Map<String, List<String>>();

        // Hardcode values (can come from metadata or a custom object later)
        List<String> typeValues = new List<String>{
            'All Categories (default)',
            'Work',
            'Personal',
            'Shopping',
            'Health',
            'Other'
        };

        List<String> priorityValues = new List<String>{
            'All Priorities (default)',
            'High',
            'Medium',
            'Low'
        };

        result.put('Type', typeValues);
        result.put('Priority', priorityValues);

        return result;
    }
}