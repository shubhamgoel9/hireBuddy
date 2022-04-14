import { LightningElement } from 'lwc';
import getNamespace from '@salesforce/apex/HirebuddyController.getNamespace';
import {namespace} from './namespaceutils';

function removeNamespaceFromKeyInObject(object) {
    
        console.log('removingNamespace: '+namespace);
        return Object.keys(object).reduce( (accu, key) => {
            console.log('key: '+key); 
        accu[key.replace(namespace, "")] = object[key]; 
        return accu;
        },{});
  };

function addNamespaceForKeyInObject(object) {
    console.log('adding namespace: '+namespace);
    return Object.keys(object).reduce( (accu, field) => {
      if(field.includes("__c")) {
        accu[namespace+`${field}`] = object[field];
      } else {
        accu[field] = object[field];
      }
      return accu;
    }, {});
  }

  export {
    removeNamespaceFromKeyInObject,
    addNamespaceForKeyInObject,
    namespace
};
export default class Utility extends LightningElement {}