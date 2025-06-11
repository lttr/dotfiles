-- https://github.com/ckolkey/ts-node-action

return {
  {
    "CKolkey/ts-node-action",
    keys = {
      {
        "<localleader>i",
        function() require("ts-node-action").node_action() end,
        desc = "Trigger TS Node Action",
      },
    },
  },
}
