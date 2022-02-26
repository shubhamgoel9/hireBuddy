/*
* VLOCITY, INC. CONFIDENTIAL
* __________________
*
*  2014-2019 Vlocity, Inc.
*  All Rights Reserved.
*
* NOTICE:  All information contained herein is, and remains
* the property of Vlocity, Inc. and its suppliers,
* if any. The intellectual and technical concepts contained
* herein are proprietary to Vlocity, Inc. and its suppliers and may be
* covered by U.S. and Foreign Patents, patents in process, and are
* protected by trade secret or copyright law. Dissemination of this
* information and reproduction, modification or reverse-engineering
* of this material, is prohibited unless prior written permission
* is obtained from Vlocity, Inc.


* Classname: IEPCHandler
*
* Author: Mohammed Ehtesham
* Version info: 107
*
* Description:
* This class executes payload-level validations
*/
public interface IEPCHandler {

     /**
      * Initializes the request handler 
      *
      *@param methodName - the method to execute on the service
      *@param Map<String,Object> inputs - Contains the payload of the request
      *@param Map<String,Object> output - Response will be added to output
      *@param Map<String,Object> options - Optional flags
      */
     void initialize(String methodName, Map<String,Object> inputs, 
                        Map<String,Object> output, Map<String,Object> options);

     /**
      * This method execute the request processing which is sub-devided into three
      * function
      * 
      * preProcess - Here input argument get parsed and initial validation is checked.
      * process - Here repositary does the processing based on request type.
      * postProcerss -  Populate the response, commit the transaction and clean up.
      */
     DomainResponse execute();
}