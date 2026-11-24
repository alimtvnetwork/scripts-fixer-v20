"""scripts/core_enums.py — Strongly typed enums for task execution."""

from enum import IntEnum, StrEnum


class ActionType(StrEnum):
    STATUS = "status"
    SCAN = "scan"
    PURGE = "purge"
    RESTART = "restart"
    REPORT = "report"


class TaskCategoryType(StrEnum):
    ALL = "all"
    OS_CACHE = "os_cache"
    DEBUG_BUILDS = "debug_builds"
    AUDIO_DEVICE = "audio_device"
    VMWARE_NETWORK = "vmware_network"
    NETWORK_STACK = "network_stack"
    APP_MAINTENANCE = "app_maintenance"
    ACCOUNT_CREATE = "account_create"


class ExitCodeType(IntEnum):
    SUCCESS = 0
    GENERAL_ERROR = 1
    INVALID_USAGE = 2
    ACCESS_DENIED = 3
