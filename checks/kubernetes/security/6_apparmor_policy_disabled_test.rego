package builtin.kubernetes.KSV002

import rego.v1

test_custom_deny if {
	r := deny with input as {
		"apiVersion": "v1",
		"kind": "Pod",
		"metadata": {
			"annotations": {"container.apparmor.security.beta.kubernetes.io/hello": "custom"},
			"name": "hello-apparmor",
		},
		"spec": {"containers": [{
			"command": [
				"sh",
				"-c",
				"echo 'Hello AppArmor!' && sleep 1h",
			],
			"image": "busybox",
			"name": "hello",
		}]},
	}

	count(r) == 1
	r[_].msg == "Container 'hello' of Pod 'hello-apparmor' should specify an AppArmor profile"
}

test_undefined_allowed if {
	r := deny with input as {
		"apiVersion": "v1",
		"kind": "Pod",
		"metadata": {"name": "hello-apparmor"},
		"spec": {"containers": [{
			"command": [
				"sh",
				"-c",
				"echo 'Hello AppArmor!' && sleep 1h",
			],
			"image": "busybox",
			"name": "hello",
		}]},
	}

	count(r) == 0
}

test_only_one_is_undefined_allowed if {
	r := deny with input as {
		"apiVersion": "v1",
		"kind": "Pod",
		"metadata": {
			"annotations": {"container.apparmor.security.beta.kubernetes.io/hello2": "runtime/default"},
			"name": "hello-apparmor",
		},
		"spec": {"containers": [
			{
				"command": [
					"sh",
					"-c",
					"echo 'Hello AppArmor!' && sleep 1h",
				],
				"image": "busybox",
				"name": "hello",
			},
			{
				"command": [
					"sh",
					"-c",
					"echo 'Hello AppArmor Again!' && sleep 1h",
				],
				"image": "busybox",
				"name": "hello2",
			},
		]},
	}

	count(r) == 0
}

test_runtime_default_allowed if {
	r := deny with input as {
		"apiVersion": "v1",
		"kind": "Pod",
		"metadata": {
			"annotations": {"container.apparmor.security.beta.kubernetes.io/hello": "runtime/default"},
			"name": "hello-apparmor",
		},
		"spec": {"containers": [{
			"command": [
				"sh",
				"-c",
				"echo 'Hello AppArmor!' && sleep 1h",
			],
			"image": "busybox",
			"name": "hello",
		}]},
	}

	count(r) == 0
}
