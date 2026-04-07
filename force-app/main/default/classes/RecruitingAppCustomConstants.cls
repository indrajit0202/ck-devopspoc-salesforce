/**
 * @description       : Class for custom constants.
 * @author            : Indrajit Pal
 * @last modified on  : 12-26-2024
 * @last modified by  : Indrajit Pal
**/
public with sharing class RecruitingAppCustomConstants {
    public static final string CANDIDATE_SEND_WELCOME_EMAIL_TEMPLATE = 'candidate welcome email';
    public static final string POSITION_STATUS_OPEN_APPROVED = 'Open - Approved';
    public static final string JOB_APPLICATION_STATUS_SCHEDULE_INTERVIEW = 'Schedule Interviews';
    public static final string JOB_APPLICATION_STATUS_INACTIVE = 'Inactive';
    public static final string JOB_APPLICATION_STATUS_WITHDRAWN = 'Withdrawn';
    public static final string JOB_APPLICATION_STATUS_NOT_SELECTED = 'Not Selected';
    public static final string JOB_APPLICATION_STATUS_INTERVIEWED = 'Interviewed';
    public static final string CLASS_STRING = 'Class.';
    public static final string DOT_STRING = '.';
    public static final string UNKNOWN_CLASS_STRING = 'UnknownClass';
    public static final string APPLICATION_WITHDRAWN_RULE_NAME = 'Application_Withdrawn_Rule';
    public static final string INACTIVE_APPLICANT_RULE_NAME = 'Inactive_Applicant_Rule';
    public static final string NOT_SELECTED_AFTER_INTERVIEW_RULE_NAME = 'Not_Selected_After_Interview_Rule'; 
    public static final string POSITION_UPDATE_SEND_EMAIL_STATIC_RESOURCE = 'positionUpdateMailTemplate';
    public static final string JOB_POSITION_UPDATE_CLOUDKAPTAN_STRING = 'Job Position update | CloudKaptan';
    public static final string EMAIL_TEMPLATE_NOT_FOUND = 'Email template not found';
    public static final string ARROW_STRING = '-->  ';
    public static final string POSITION_TEMPLATE_NOT_FOUND = 'Position Template not found';
    public static final string CANDIDATE_ID = 'Id';
    public static final string TESTING = 'testing';
    public static final string UNDERSCORE_STRING = '_';
    public static final string RESUME_STRING = '_Resume';
    public static final string BLANK_STRING = ' ';
    public static final string LINE_CHANGE = '\n';
    public static final string AUTO_RESUME_GENERATE_TRIGGER_HANDLER_ERROR_MESSAGE = 'Something went wrong in the job application trigger handler for resume generation, Please contact system admin';
    public static final string JOB_APPLICATION_STATUS_UPDATE_BATCH_JOB_NAME = 'JobApplicationStatusUpdateBatchScheduler';
}