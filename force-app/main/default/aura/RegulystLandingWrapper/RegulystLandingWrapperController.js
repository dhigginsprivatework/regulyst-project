({
    handleNavigate: function(component, event) {
        const workspaceAPI = component.find("workspace");
        const url = event.getParam("url");

        workspaceAPI.openTab({
            url: url,
            focus: true
        }).catch(function(error) {
            console.error("Error opening tab: ", error);
        });
    }
})
