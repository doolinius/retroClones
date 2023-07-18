def readAccounts(acctFileName):
    acctFile = open(acctFileName, "r") # open the file
    accountList = []  # create an empty list
    for line in acctFile.readlines():  # for each line in the file...
        account = line.split(',')      # split the line into a list of strings
        account[3] = float(account[3]) # convert the 4th element to a float because it's a balance figure
        accountList.append(account)    # add that account to the accountList
    return(accountList)  # we're all done, return the list

def validTransaction(transaction, acctList):
    # check to see if it has the right number of fields
    if len(transaction) != 3:
        print("Invalid number of fields")
        return(False)

    # check to see if the transaction type is "withdrawal" or "deposit"
    if transaction[1] != "withdrawal" and transaction[1] != "deposit":
        print("Invalid transaction type")
        return(False)

    # check to see if it is a valid account number
    # for each account in the list...
    for account in acctList:
        acctNum = account[0]  # ... get the account number
        if transaction[0] == acctNum:  # Check if the one in the transaction is equal
            return(True)   # if so, YAY, we found it and it's a valid transaction

    # if we got here, it's an invalid account number so...
    print("Invalid account number")
    return(False)

def readTransactions(transFileName):
    transFile = open(transFileName, "r")
    transactions = []  # create an empty list for valid transactions
    for line in transFile.readlines():  # for each line in the file
        transaction = line.split(',')  # split the line
        if isValid(transaction):        # check to see if it's a valid transaction
            transaction[2] = float(transaction[2])  # data conversion
            transactions.append(transaction)   # append to the list

def main():
    accounts = readAccounts("accounts.csv")
    transactions = readTransactions("transactions.csv")
    print("# of accounts:", len(accounts))
    print("# of valid transactions:", len(transactions))

main()
