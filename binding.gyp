{
  "targets": [
    {
      "target_name": "NativeExtension",
      "sources": ["NativeExtension.cc"],
      "conditions": [
        [
          "OS==\"mac\"",
          {
            "sources": ["tint.mm"],
            "link_settings": {
              "libraries": ["-framework AppKit"]
            }
          }
        ]
      ]
    }
  ]
}
