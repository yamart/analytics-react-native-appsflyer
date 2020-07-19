declare const AppsFlyer:
    | {disabled: true}
    | (() => Promise<void>)

declare const onInstallConversionData: Function;

export {
    AppsFlyer,
    onInstallConversionData
}
