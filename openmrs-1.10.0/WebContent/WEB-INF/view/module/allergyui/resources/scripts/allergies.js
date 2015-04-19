var confirmNoKnownAllergyDialog = null;

$(document).ready( function() {

    confirmNoKnownAllergyDialog = emr.setupConfirmationDialog({
        selector: '#allergyui-confirm-no-known-allergy-dialog',
        actions: {
            cancel: function() {
                confirmNoKnownAllergyDialog.close();
            }
        }
    });

});

function showConfirmNoKnownAllergyDialog() {
    confirmNoKnownAllergyDialog.show();
}