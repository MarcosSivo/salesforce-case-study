/**
 * @description Public Apex REST webhook for external application submissions.
 */
@RestResource(urlMapping='/external/applications')
global without sharing class ApplicationWebhook {
    /**
     * @description Receives an application payload, processes it, and returns the created record details.
     * @return ApplicationResult payload describing the result.
     */
    @HttpPost
    global static ApplicationResult handlePost() {
        ApplicationResult response = new ApplicationResult();

        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;

        try {
            String body = req != null && req.requestBody != null ? req.requestBody.toString() : null;

            if (String.isBlank(body)) {
                res.statusCode = 400;
                response.success = false;
                response.message = 'Request body is required.';
                return response;
            }

            ApplicationDTO input = (ApplicationDTO) JSON.deserialize(body, ApplicationDTO.class);
            ApplicationResult result = ApplicationProcessingService.processApplication(input, 'Webhook');

            if (result != null && result.success == true) {
                res.statusCode = 200;
                response.success = true;
                response.recordType = result.recordType;
                response.recordId = (String) result.recordId;
                response.message = 'Application processed successfully';
                return response;
            }

            res.statusCode = 400;
            response.success = false;
            response.message = result != null ? result.message : 'Application processing failed.';
            return response;
        } catch (Exception ex) {
            res.statusCode = 500;
            response.success = false;
            response.message = ex.getMessage();
            return response;
        }
    }
}