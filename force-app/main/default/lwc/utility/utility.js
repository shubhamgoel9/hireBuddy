import { LightningElement } from 'lwc';
import {namespace} from './namespaceutils';

function removeNamespaceFromKeyInObject(object) {
    
    return Object.keys(object).reduce( (accu, key) => {
        accu[key.replace(namespace, "")] = object[key]; 
        return accu;
        },{});
  };

function addNamespaceForKeyInObject(object) {
    return Object.keys(object).reduce( (accu, field) => {
      if(field.includes("__c")) {
        accu[namespace+field] = object[field];
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