/**
 * @description       : This class implements the Schedulable interface to schedule and execute a batch job 
 *                      that updates the status of job applications.
 * @author            : Indrajit Pal
 * @last modified on  : 12-26-2024
 * @last modified by  : Indrajit Pal
**/
global with sharing class JobApplicationStatusUpdateBatchScheduler implements Schedulable {
    /**
    * @description Executes the batch job logic to process job application status updates. 
    * @author Indrajit Pal | 12-26-2024 
    * @param sc 
    **/
    global void execute(SchedulableContext sc) {
        JobApplicationStatusUpdateBatch jobAppStusUpdteBatch = new JobApplicationStatusUpdateBatch(); 
        database.executebatch(jobAppStusUpdteBatch, 200);
    }

    /**
    * @description Schedules the batch job to run at 10:30 PM every day using a cron expression. 
     *             This method can be called once to programmatically schedule the batch job.
    * @author Indrajit Pal | 12-26-2024 
    **/
    public static void scheduleJob() {
        String cronExpression = '0 30 22 * * ?'; 
        String jobName = RecruitingAppCustomConstants.JOB_APPLICATION_STATUS_UPDATE_BATCH_JOB_NAME;
        
        JobApplicationStatusUpdateBatchScheduler scheduler = new JobApplicationStatusUpdateBatchScheduler();
        System.schedule(jobName, cronExpression, scheduler);
    }
}
