import { LightningElement, track, wire } from 'lwc';
import getObjectList from '@salesforce/apex/FieldReportController.getObjectList';
import getFields from '@salesforce/apex/FieldReportController.getFields';

export default class ObjectPicker extends LightningElement {
    @track objectOptions = [];
    @track selectedObject = '';
    @track number = 0;
    @track fields;
    @track error;


    @wire(getObjectList)
    wiredObjects({ error, data }) {
        if (data) {
            this.objectOptions = data.map((obj, index) => {
                return { label: obj.label, value: obj.name, id: index };
            });
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.objectOptions = [];
        }
    }

    handleObjectChange(event) {
        this.selectedObject = event.detail.value;
    }

    handleNumberChange(event) {
        this.number = event.detail.value;
    }

    handleButtonClick() {
        getFields({ sObjectName: this.selectedObject, years: this.number })
            .then(result => {
                this.fields = result;
                if (result.length > 0) { this.columns = Object.keys(result[0]).map(key => { return { label: key.charAt(0).toUpperCase() + key.slice(1), fieldName: key, type: 'text' }; }); }

                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.fields = undefined;
            });
    }
}
