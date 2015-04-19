<%
    if (sessionContext.authenticated && !sessionContext.currentProvider) {
        throw new IllegalStateException("Logged-in user is not a Provider")
    }
    ui.decorateWith("appui", "standardEmrPage")
    ui.includeJavascript("uicommons", "navigator/validators.js", Integer.MAX_VALUE - 19)
    ui.includeJavascript("uicommons", "navigator/navigator.js", Integer.MAX_VALUE - 20)
    ui.includeJavascript("uicommons", "navigator/navigatorHandlers.js", Integer.MAX_VALUE - 21)
    ui.includeJavascript("uicommons", "navigator/navigatorModels.js", Integer.MAX_VALUE - 21)
    ui.includeJavascript("uicommons", "navigator/exitHandlers.js", Integer.MAX_VALUE - 22)
%>
${ ui.includeFragment("uicommons", "validationMessages")}

<script type="text/javascript">
    jQuery(function() {
        KeyboardController();
    });
</script>

<script type="text/javascript">
    var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm' },
        { label: "${ ui.message("dispensing.app.label") }", link: "${ ui.pageLink("dispensing", "dispenseMedication") }" }
    ];
</script>

<div id="content" class="container">
    <h2>
        ${ ui.message("dispensing.app.label") }
    </h2>

    <form class="simple-form-ui" id="dispensing" method="POST">
        <section id="information" style="min-width: 50%">
            <span class="title">${ui.message("dispensing.app.dispensing.title")}</span>

            <fieldset>
                <legend>${ui.message("dispensing.app.information.title")}</legend>
                ${ ui.includeFragment("uicommons", "field/datetimepicker", [
                        label: ui.message("dispensing.app.date.label"),
                        formFieldName: "date",
                        useTime: true,
                        classes: ["required"]
                 ])}
                <%
                    def prescribersList = []
                    prescribers.each {
                        prescribersList.add([ value: it.providerId, label: it.identifier ])
                    }
                %>
                ${ ui.includeFragment("uicommons", "field/dropDown", [
                        label: ui.message("dispensing.app.prescriber.label"),
                        formFieldName: "prescriber",
                        classes: ["required"],
                        options: prescribersList
                ])}
            </fieldset>
            <fieldset>
                <legend>${ui.message("dispensing.app.medication.title")}</legend>
                ${ ui.includeFragment("uicommons", "field/dropDown", [
                        label: ui.message("dispensing.app.name.label"),
                        formFieldName: "name",
                        classes: ["required"],
                        options: [
                                [value: "Advil", label: "Advil"],
                                [value: "Actron", label: "Actron"],
                                [value: "Aleve", label: "Aleve"]
                        ]
                ])}
                ${ ui.includeFragment("uicommons", "field/text", [
                        label: ui.message("dispensing.app.frequency.label"),
                        formFieldName: "frequency",
                        left: true
                ])}
                ${ ui.includeFragment("uicommons", "field/dropDown", [
                        label: "&nbsp;",
                        formFieldName: "frequency_units",
                        left: true,
                        options: [
                            [value: "every day", label: "every day"],
                            [value: "every 2 days", label: "every 2 days"],
                            [value: "every 3 days", label: "every 3 days"],
                            [value: "every 4 days", label: "every 4 days"],
                            [value: "every week", label: "every week"],
                            [value: "every 2 weeks", label: "every 2 weeks"]
                        ]
                ])}
                <div class="clear" />
                ${ ui.includeFragment("uicommons", "field/text", [
                        label: ui.message("dispensing.app.dose.label"),
                        formFieldName: "dose",
                        left: true,
                ])}
                ${ ui.includeFragment("uicommons", "field/dropDown", [
                        label: "&nbsp;",
                        formFieldName: "dose_units",
                        left: true,
                        options: [
                            [value: "mg", label: "mg"],
                            [value: "micorgram", label: "microgram"],
                            [value: "mg/mil", label: "mg/mil"],
                            [value: "microgram/mil", label: "microgram/mil"],
                            [value: "microgram/hour", label: "microgram/hour"],
                            [value: "mL", label: "m:"],
                            [value: "grams", label: "grams"],
                            [value: "international units", label: "international units"],
                            [value: "million international units", label: "million international units"]
                        ]
                ])}
                <div class="clear" />
                ${ ui.includeFragment("uicommons", "field/text", [
                        label: ui.message("dispensing.app.duration.label"),
                        formFieldName: "duration",
                        left: true,
                ])}
                <p class="left"><p>&nbsp;</p><p>&nbsp;days</p></p>
                <div class="clear" />
                ${ ui.includeFragment("uicommons", "field/text", [
                        label: ui.message("dispensing.app.amount.label"),
                        formFieldName: "amount",
                        left: true,
                ])}
                ${ ui.includeFragment("uicommons", "field/dropDown", [
                        label: "&nbsp;",
                        formFieldName: "amount_units",
                        left: true,
                        options: [
                            [value: "tablet", label: "tablet"],
                            [value: "tube", label: "tube"],
                            [value: "capsule", label: "capsule"],
                            [value: "bottle", label: "bottle"],
                            [value: "inhaler", label: "inhaler"],
                            [value: "application", label: "application"],
                            [value: "patch", label: "patch"],
                            [value: "sachet", label: "sachet"],
                            [value: "vial", label: "vial"],
                            [value: "suppository", label: "suppository"]
                        ]
                ])}
                <div class="clear" />
            </fieldset>

        </section>
        <div id="confirmation">
            <span class="title">${ui.message("dispensing.app.confirm.label")}</span>
            <div class="before-dataCanvas"></div>
            <div id="dataCanvas"></div>
            <div class="after-data-canvas"></div>
            <div id="confirmationQuestion">
                Confirm submission? <p style="display: inline"><input type="submit" class="confirm" value="Yes" /></p> or <p style="display: inline"><input id="cancelSubmission" class="cancel" type="button" value="No" /></p>
            </div>
        </div>
    </form>
</div>
