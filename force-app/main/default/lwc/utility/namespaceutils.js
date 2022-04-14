import getNamespace from '@salesforce/apex/HirebuddyController.getNamespace';

let namespace = '';
(async function () {
     await getNamespace().then(result=>{
        console.log('Prit: nsp in namespaceutils: '+result);
        namespace = result;
    }).catch(error=>{
        this.error = error;
    })
})();

export {
    namespace
}
