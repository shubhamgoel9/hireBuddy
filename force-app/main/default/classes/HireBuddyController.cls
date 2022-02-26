global with sharing class HireBuddyController {
    public HireBuddyController() {
    }
    @RemoteAction
    global static Object invokeMethod(String methodName, String serializedInputs) {
        System.debug('HireBuddyController');
        Map<String, Object> inputs = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        if (serializedInputs != null) {
            inputs = (Map<String, Object>)JSON.deserializeUntyped(serializedInputs);
        }
        try
        {
            IEPCHandler reqHandler = new EPCBaseHandler();
            if(reqHandler != null){
                reqHandler.initialize(methodName, inputs, output, options);
                DomainResponse response = reqHandler.execute();
                return response.toOutputMap();
            }
        }
        catch (Exception e)
        {
            
            System.debug('ProductConsoleController2 Exception: ' + e.getStackTraceString());
        }
        return null;
    }
}