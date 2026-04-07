/**
 * @description       : 
 * @author            : Indrajit Pal
 * @last modified on  : 04-08-2026
 * @last modified by  : Indrajit Pal
**/
@isTest
public with sharing class JobAppStatusUpdateBatchSchedulerTest {

@isTest
    static void testJobApplicationStatusUpdateBatchScheduler() {
        Test.startTest();
        // Schedule the batch job
        String jobId = System.schedule('JobApplicationStatusUpdateBatchScheduler', 
            '0 0 0 3 9 ? 2022', new JobApplicationStatusUpdateBatchScheduler());
        Test.stopTest();

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                            FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals('0 0 0 3 9 ? 2022', ct.CronExpression);
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
        // Verify the next expected run time
        System.assertEquals('{DATE_PLACEHOLDER} 00:00:00', String.valueOf(ct.NextFireTime));
        
        // Verify jobId is not null
        System.assertNotEquals(null, jobId); 
    }
}