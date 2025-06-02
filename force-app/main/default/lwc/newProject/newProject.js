import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import createProjectWithMilestonesAndTasks from '@salesforce/apex/ProjectMilestoneController.createProjectWithMilestonesAndTasks';

export default class NewProject extends LightningElement {
    @track projectName = '';
    @track milestones = [];
    userId = ''; 

    handleProjectNameChange(event) {
        this.projectName = event.target.value;
    }

    handleProjectOwnerChange(event) {
        this.userId = event.detail.recordId;
    }

    addMilestone() {
        const milestoneId = this.generateUniqueId();
        this.milestones = [
            ...this.milestones,
            { id: milestoneId, name: '', toDos: [] }
        ];
    }

    addToDo(event) {
        const milestoneId = event.target.dataset.milestoneId;
        const todoId = this.generateUniqueId();
        this.milestones = this.milestones.map(milestone => {
            if (milestone.id === milestoneId) {
                milestone.toDos = [...milestone.toDos, { id: todoId, name: '' }];
            }
            return milestone;
        });
    }

    handleMilestoneNameChange(event) {
        const milestoneId = event.target.dataset.id;
        const milestoneName = event.target.value;
        this.milestones = this.milestones.map(milestone => {
            if (milestone.id === milestoneId) {
                milestone.name = milestoneName;
            }
            return milestone;
        });
    }

    handleToDoNameChange(event) {
        const milestoneId = event.target.dataset.milestoneId;
        const todoId = event.target.dataset.todoId;
        const todoName = event.target.value;
        this.milestones = this.milestones.map(milestone => {
            if (milestone.id === milestoneId) {
                milestone.toDos = milestone.toDos.map(todo => {
                    if (todo.id === todoId) {
                        todo.name = todoName;
                    }
                    return todo;
                });
            }
            return milestone;
        });
    }

    handleRemoveMilestone(event) {
        const milestoneId = event.target.dataset.id;
        this.milestones = this.milestones.filter(milestone => milestone.id !== milestoneId);
    }

    handleRemoveToDo(event) {
        const todoId = event.target.dataset.id;
        const milestoneId = event.target.dataset.milestoneId;
        this.milestones = this.milestones.map(milestone => {
            if (milestone.id === milestoneId) {
                milestone.toDos = milestone.toDos.filter(todo => todo.id !== todoId);
            }
            return milestone;
        });
    }

    handleSubmit() { 
        console.log('handleSubmit '+ this.userId);
        
        const milestones = this.milestones.map(milestone => ({
            id: milestone.id,
            name: milestone.name
          }));
          console.log('milestones '+ milestones);
          
        const toDos = this.milestones.map(milestone =>
            milestone.toDos.map(toDo => ({
                id: toDo.id,
                idMilestone: milestone.id,
                name: toDo.name
            }))
        );

        var objApex = {
            listMilestones : milestones,
            listToDos : toDos.flat()
        }
        console.log('toDostoDos '+ JSON.stringify(objApex));

        //Validade Owner
        if(!this.userId){
            this.showInfoToast('Warning', 'warning', 'Please fill the owner of the project before you send');
            return;
        }
        
        //Validate name
        if(!this.projectName){
            this.showInfoToast('Warning', 'warning', 'Please fill the name of the project before you send');
            return;
        }
        //Validations
        if(objApex.listMilestones.length == 0 || objApex.listToDos.length == 0){
            this.showInfoToast('Warning', 'warning', 'Create one milestone and one to-do');
            return;
        }
        var containsError = false;
        //Validate Records
        objApex.listMilestones.forEach(element => {
            console.log('Milestone-name '+ element.name);
            if(!element.name){
                containsError = true;
                this.showInfoToast('Warning', 'warning', 'Please fill all the name fields of the Milestones before you send');
                return;
            } 
                         
        });

        objApex.listToDos.forEach(element => {
            console.log('Todo-name '+ element.name);
            if(!element.name){
                containsError = true;
                this.showInfoToast('Warning', 'warning', 'Please fill all the name fields of the To-dos before you send');
                return;
            }         
        });
        if(containsError) return;

        createProjectWithMilestonesAndTasks({valuesJson : JSON.stringify(objApex) , projectName : this.projectName, ownerId : this.userId})
            .then((projectId) => {
                console.log('Deu good');
                this.showInfoToast('Success', 'success', 'Project created with sucess');
                console.log('projectId '+ projectId);

                window.open('/' + projectId, "_parent");
            })
            .catch(error => {
                this.showInfoToast('Error', 'error', error.body.message);
            });
    }

    generateUniqueId() {
        return Date.now().toString(36) + Math.random().toString(36).substr(2, 5);
    }
    showInfoToast(title, variant, message ){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
        
    
}