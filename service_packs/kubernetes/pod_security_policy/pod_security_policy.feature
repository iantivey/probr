@k-psp
@probes/kubernetes/pod_security_policy
Feature: Maximise security through Pod Security Policies

As a Cloud Security Administrator
I want to ensure that a stringent set of Pod Security Policies are present
So that a policy of least privilege can be enforced in order to prevent malicious attacks on my organization

#Rule: Insert tags here. ... for some reason 'Rule:' doesn't work in latest godog ..
#TODO: for 5.2.1 .. these are all 'creation', so 'deployment running' should be changed to 'deployment created'
#TODO: question .. how specific should we be on the control terminology?  e.g. should we stick with
# the below, or specific, like "And 'isPrivileged' is set to <true|false>"??
#TODO: also ... for 5.2.5, we can test to prevent creation, but what about trying to execute a cmd which reqs root?
# think we should do that, but is that a separate scenario or blend into this one?  for some this makes sense - mark with @detective?

    @k-psp-001
    Scenario Outline: Prevent a deployment from running with privileged access
        Given a Kubernetes cluster exists which we can deploy into
        And some system exists to prevent a Kubernetes deployment running with privileged access in an existing Kubernetes cluster
        When a Kubernetes deployment is applied to an existing Kubernetes cluster
        And privileged access request is marked "<privileged access requested>" for the Kubernetes deployment
        Then the operation will "<RESULT>" with an error "<ERRORMESSAGE>"
        But I should not be able to perform a command that requires privileged access
        And I should be able to perform an allowed command

        Examples:
            | privileged access requested | RESULT        | ERRORMESSAGE                                 |
            | True                        | Fail          | Containers with privileged access can't run  |
            | False                       | Succeed       | No error would show                          |
            | Not Defined                 | Succeed       | No error would show                          |

    @k-psp-002
    Scenario Outline: Prevent a deployment from running with the hostPID
        Given a Kubernetes cluster exists which we can deploy into
        And some system exists to prevent a Kubernetes deployment from running using the hostPID in an existing Kubernetes cluster
        When a Kubernetes deployment is applied to an existing Kubernetes cluster
        And hostPID request is marked "<HostPID requested>" for the Kubernetes deployment
        Then the operation will "<RESULT>" with an error "<ERRORMESSAGE>"
        But I should not be able to perform a command that provides access to the host PID namespace
        And I should be able to perform an allowed command

        Examples:
            | HostPID requested           | RESULT        | ERRORMESSAGE                                 |
            | True                        | Fail          | Containers cant run using hostPID            |
            | False                       | Succeed       |                                              |
            | Not Defined                 | Succeed       |                                              |

    @k-psp-003
    Scenario Outline: Prevent a deployment from running with the hostIPC flag.
        Given a Kubernetes cluster exists which we can deploy into
        And some system exists to prevent a Kubernetes deployment from running using the hostIPC in an existing Kubernetes cluster
        When a Kubernetes deployment is applied to an existing Kubernetes cluster
        And hostIPC request is marked "<hostIPC access is requested>" for the Kubernetes deployment
        Then the operation will "<RESULT>" with an error "<ERRORMESSAGE>"
        But I should not be able to perform a command that provides access to the host IPC namespace
        And I should be able to perform an allowed command

        Examples:
            | hostIPC access is requested | RESULT   | ERRORMESSAGE                        |
            | True                        | Fail     | Containers with hostIPC access can't run |
            | False                       | Succeed  | No error would show                      |
            | Not defined                 | Succeed  | No error would show                      |

    @k-psp-004
    Scenario Outline: Prevent a deployment from running with the hostNetwork flag.
        Given a Kubernetes cluster exists which we can deploy into
        And some system exists to prevent a Kubernetes deployment from running using the hostNetwork in an existing Kubernetes cluster
        When a Kubernetes deployment is applied to an existing Kubernetes cluster
        And hostNetwork request is marked "<hostNetwork access is requested>" for the Kubernetes deployment
        Then the operation will "<RESULT>" with an error "<ERRORMESSAGE>"
        But I should not be able to perform a command that provides access to the host network namespace
        And I should be able to perform an allowed command

        Examples:
            | hostNetwork access is requested | RESULT   | ERRORMESSAGE |
            | True                              | Fail     | Containers with hostNetwork access can't run |
            | False                           | Succeed  | No error would show                      |
            | Not defined                     | Succeed  | No error would show                      |

    @k-psp-005
    Scenario Outline: Prevent a deployment from running with the allowPrivilegeEscalation flag
        Given a Kubernetes cluster exists which we can deploy into
        And some system exists to prevent a Kubernetes deployment from running using the allowPrivilegeEscalation in an existing Kubernetes cluster
        When a Kubernetes deployment is applied to an existing Kubernetes cluster
        And privileged escalation is marked "<AllowPrivilegeEscalation requested>" for the Kubernetes deployment
        Then the operation will "<RESULT>" with an error "<ERRORMESSAGE>"
        But I should not be able to perform a sudo command that requires privileged access
        And I should be able to perform an allowed command

        Examples:
            | AllowPrivilegeEscalation requested | RESULT        | ERRORMESSAGE                                                   |
            | True                               | Fail          | Containers cant run using the allowPrivilegeEscalation flag |
            | False                              | Succeed       | No error would show                                         |
            | Not Defined                        | Succeed       | No error would show                                         |

    @k-psp-006
    Scenario Outline: Prevent a deployment from running as the root user
        Given a Kubernetes cluster exists which we can deploy into
        And some system exists to prevent a Kubernetes deployment from running as the root user in an existing Kubernetes cluster
        When a Kubernetes deployment is applied to an existing Kubernetes cluster
        And the user requested is "<requested user>" for the Kubernetes deployment
        Then the operation will "<RESULT>" with an error "<ERRORMESSAGE>"
        And the Kubernetes deployment should run with a non-root UID
        And I should be able to perform an allowed command

        Examples:
            | requested user | RESULT   | ERRORMESSAGE                  |
            | Root           | Fail     | Containers cant run as root |
            | Non-Root       | Succeed  |                             |
            | Not Defined    | Succeed  |                             |

    @k-psp-007
    Scenario Outline: Prevent deployments from running with the NET_RAW capability.

    Assuming cluster is configured to prevent NET_RAW capabilities:
    - If a container explicitly adds NET_RAW it should fail to deploy
    - If a container explicitly drops NET_RAW it should succeed to deploy
    - If a container doesn't add neither drop NET_RAW it should fail to deploy, since cluster will require explicit drop

        Given a Kubernetes cluster exists which we can deploy into
        When a Kubernetes deployment with NET_RAW capability "<NET_RAW_Option>" is applied to an existing Kubernetes cluster
        Then the operation will "<RESULT>" with an error "<ERRORMESSAGE>"

        Examples:
            | NET_RAW_Option     | RESULT  | ERRORMESSAGE                                  |
            | Added              | Fail    | Containers cant run with NET_RAW capabilities |
            | Dropped            | Succeed |                                               |
            | Not Defined        | Fail    | Containers cant run with NET_RAW capabilities |

    @k-psp-008
    Scenario Outline: Prevent container running with capabilities beyond the default set.
        Given a Kubernetes cluster exists which we can deploy into
        And some system exists to prevent Kubernetes deployments with capabilities beyond the default set from being deployed to an existing kubernetes cluster
        When a Kubernetes deployment is applied to an existing Kubernetes cluster
        And additional capabilities requested for the Kubernetes deployment are "<allowed>" allowed
        Then all operations will "<RESULT>" with an error "<ERRORMESSAGE>"
        But I should not be able to perform a command that requires capabilities outside of the default set
        And I should be able to perform an allowed command

        Examples:
            | allowed     | RESULT  | ERRORMESSAGE                                    |
            | NOT         | Fail    | Containers can't run with added capabilities    |
            | ARE         | Succeed |                                                 |
            | Not Defined | Succeed |                                                 |

    @k-psp-009
    Scenario Outline: Prevent deployments from running with assigned capabilities.
        Given a Kubernetes cluster exists which we can deploy into
        And some system exists to prevent Kubernetes deployments with assigned capabilities from being deployed to an existing Kubernetes cluster
        When a Kubernetes deployment is applied to an existing Kubernetes cluster
        And assigned capabilities "<requested>" requested for the Kubernetes deployment
        Then the operation will "<RESULT>" with an error "<ERRORMESSAGE>"
        But I should not be able to perform a command that requires any capabilities
        And I should be able to perform an allowed command

        Examples:
            | requested   | RESULT  | ERRORMESSAGE                                            |
            | ARE         | Fail    | Containers with assigned capabilities can't be deployed |
            | ARE NOT     | Succeed |                                                         |
            | Not defined | Succeed |                                                         |

    @k-psp-010
    Scenario Outline: Prevent deployments from accessing unapproved volume types
        Given a Kubernetes cluster exists which we can deploy into
        And some system exists to prevent Kubernetes deployments with unapproved volume types from being deployed to an existing Kubernetes cluster
        When a Kubernetes deployment is applied to an existing Kubernetes cluster
        And "<requested>" volume types are requested for the Kubernetes deployment
        Then all operations will "<RESULT>" with an error "<ERRORMESSAGE>"

        Examples:
            | requested   | RESULT     | ERRORMESSAGE                           |
            | unapproved  | Fail       | Cannot access unapproved volume type   |
            | approved    | Succeed    |                                        |

    @k-psp-011
    Scenario Outline: Prevent deployments from running without approved seccomp profile
        Given a Kubernetes cluster exists which we can deploy into
        And some system exists to prevent Kubernetes deployments without approved seccomp profiles from being deployed to an existing Kubernetes cluster
        When a Kubernetes deployment is applied to an existing Kubernetes cluster
        And an "<requested>" seccomp profile is requested for the Kubernetes deployment
        Then the operation will "<RESULT>" with an error "<ERRORMESSAGE>"
        But I should not be able to perform a system call that is blocked by the seccomp profile
        And I should be able to perform an allowed command

        Examples:
            | requested  | RESULT    | ERRORMESSAGE                                |
            | unapproved | Fail      | Cannot request unapproved seccomp profile   |
            | approved   | Succeed   | no error                                    |
            | undefined  | Fail      | Approved seccomp profile required           |

    @k-psp-012
    Scenario Outline: Prevent pods from exposing unapproved host ports
    		Given a Kubernetes cluster exists which we can deploy into
    		And some system exists to prevent Kubernetes deployments with unapproved port range from being deployed to an existing Kubernetes cluster
        When a Kubernetes deployment is applied to an existing Kubernetes cluster
    		And an "<requested>" hostPort is requested for the Kubernetes deployment
    		Then the operation will "<RESULT>" with an error "<ERRORMESSAGE>"

    		Examples:
    			| requested 	| RESULT 	| ERRORMESSAGE							          |
    			| unapproved  | Fail  	| Cannot access unapproved port range	|
    			| not defined	| Succeed	|	                                    |

    @k-psp-013
    Scenario: Prevent deployments from executing commands with the NET_RAW capability.

    Assuming cluster is configured to prevent NET_RAW capabilities:
    - A container with explicit drop NET_RAW is deployed
    - A command that doesn't require NET_RAW (such as ls) should succeed
    - A command that requires NET_RAW (such as ping www.google.com) should fail

        Given a Kubernetes cluster exists which we can deploy into
        When a Kubernetes deployment with NET_RAW capability "Dropped" is applied to an existing Kubernetes cluster
        Then the operation will "Succeed" with an error ""
        And I should be able to perform an allowed command
        But I should not be able to perform a command that requires NET_RAW capability
