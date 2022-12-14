*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library           RPA.Dialogs
Library           RPA.HTTP
Library           RPA.Tables
Library           RPA.Browser.Selenium    auto_close=${FALSE}
Library           RPA.PDF
Library           RPA.Archive
Library           RPA.FileSystem


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${robot_orders}=    Get orders
    FOR    ${row}    IN    @{robot_orders}
        Close the annoying modal
        Fill the form    ${row}
        Wait Until Keyword Succeeds    30s    1s    Preview the robot
        Wait Until Keyword Succeeds    30s    1s    Submit the order
        ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
        ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Go to order another robot
    END
    Close the browser

*** Keywords ***

Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order    

Get orders
    Download    https://robotsparebinindustries.com/orders.csv          overwrite=True
    ${orders}=    Read table from CSV    orders.csv
    Log    Found columns: ${orders.columns}
    [Return]    ${orders}

Close the annoying modal
    Click Button    xpath://button[contains(.,'OK')]

Fill the form
    [Arguments]    ${row}
    Wait Until Element Is Visible    id:head
    Select From List By Value    id:head    ${row}[Head]
    Click Element    xpath=//*[@id="id-body-${row}[Body]"]
    Input Text    xpath=//input[@placeholder="Enter the part number for the legs"]    ${row}[Legs]
    Input Text    css:#address    ${row}[Address]

Preview the robot
    Click Element    id:preview
    Wait Until Element Is Visible    id:preview    2s

Submit the order
    Click Element    id:order
    Wait Until Element Is Visible    id:order-completion    2s

Store the receipt as a PDF file
    [Arguments]    ${order_number}
    ${order_completion_html}=    Get Element Attribute    id:order-completion    innerHTML
    Html To Pdf    ${order_completion_html}    ${OUTPUT_DIR}${/}robot_orders${/}robot_${order_number}.pdf

Take a screenshot of the robot
    [Arguments]    ${order_number}
    Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}screenshots${/}robot_screenshot_${order_number}.png
    Open Pdf    ${OUTPUT_DIR}${/}robot_orders${/}robot_${order_number}.pdf
    ${files}=    Create List    ${OUTPUT_DIR}${/}screenshots${/}robot_screenshot_${order_number}.png
    Add Files To Pdf    ${files}    ${OUTPUT_DIR}${/}robot_orders${/}robot_${order_number}.pdf    append=True
    Close Pdf

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    No Operation

Go to order another robot
    Click Element    id:order-another

Create a ZIP file of the receipts
    Archive Folder With ZIP    ${OUTPUT_DIR}${/}robot_orders    ${OUTPUT_DIR}${/}robot_orders.zip    recursive=False    include=order*.pdf

Close the browser
    Add icon    Warning
    Add heading    Close the browser
    Add submit buttons    close
    ${result}=    Run dialog
    IF    $result.submit == "close"    close browser
    
        
         