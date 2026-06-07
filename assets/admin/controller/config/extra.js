!function () {
    const _config = getVar('_config');

    function _Save() {
        $('.save-data').click(function () {
            util.post("/admin/api/config/extra", util.arrayToObject($("#data-form").serializeArray()), res => {
                layer.msg(res.msg);
            });
        });
    }

    _Save();
}();
