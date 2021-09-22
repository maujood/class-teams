## How to run this project

    sfdx force:org:create -s -f config/project-scratch-def.json -a  myscratchorg
    sfdx force:source:push
    sfdx force:permset:assign
    sfdx force:org:open

## Class Team for Custom Objects

This project demonstrates an example of implementing teams for custom objects. Class Team Members can be added to the Class object. 

### Why not manual sharing?

Because manual sharing records are deleted on record ownership changes and can only be managed to record owners, individuals higher than the owner in the role hierarchy or individuals with "Modify All" permissions to the object. A custom implementation allows sharing to persist through record changes and allows more control over who exactly adds/remove team members.