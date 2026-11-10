sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"supplierdataissuesapp/test/integration/pages/DataIssuesList.gen",
	"supplierdataissuesapp/test/integration/pages/DataIssuesObjectPage.gen"
], function (JourneyRunner, DataIssuesListGenerated, DataIssuesObjectPageGenerated) {
    'use strict';

    const runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('supplierdataissuesapp') + '/test/flp.html#app-preview',
        pages: {
			onTheDataIssuesListGenerated: DataIssuesListGenerated,
			onTheDataIssuesObjectPageGenerated: DataIssuesObjectPageGenerated
        },
        async: true
    });

    return runner;
});

