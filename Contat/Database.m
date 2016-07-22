#import "Database.h"
static Database *shareDatabase =nil;

@implementation Database

#pragma mark - Database

+(Database*) shareDatabase{
    
    if(!shareDatabase){
        shareDatabase = [[Database alloc] init];
    }
    
    return shareDatabase;
    
}

#pragma mark - Get DataBase Path

NSString * const DataBaseName  = appDBName; // Paas Your DataBase Name Over here

- (NSString *) GetDatabasePath:(NSString *)dbName{
    NSArray  *paths        = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    
    NSLog(@"%@",[documentsDir stringByAppendingPathComponent:dbName]);
    return [documentsDir stringByAppendingPathComponent:dbName];
}

-(BOOL) createEditableCopyOfDatabaseIfNeeded
{
    BOOL success;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:DataBaseName];
    
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) return success;
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DataBaseName];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    
    if (!success) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!!!" message:@"Failed to create writable database" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    return success;
}

#pragma mark - Get All Record

-(NSMutableArray *)SelectAllFromTable:(NSString *)query
{
    sqlite3_stmt *statement = nil ;
    NSString *path = [self GetDatabasePath:DataBaseName];
    
    NSMutableArray *alldata;
    alldata = [[NSMutableArray alloc] init];
    
    if(sqlite3_open([path UTF8String],&databaseObj) == SQLITE_OK )
    {
        if((sqlite3_prepare_v2(databaseObj,[query UTF8String],-1, &statement, NULL)) == SQLITE_OK)
        {
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                
                NSMutableDictionary *currentRow = [[NSMutableDictionary alloc] init];
                
                int count = sqlite3_column_count(statement);
                
                for (int i=0; i < count; i++) {
                    
                    char *name = (char*) sqlite3_column_name(statement, i);
                    char *data = (char*) sqlite3_column_text(statement, i);
                    
                    NSString *columnData;
                    NSString *columnName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
                    
                    if(data != nil){
                        columnData = [NSString stringWithCString:data encoding:NSUTF8StringEncoding];
                    }else {
                        columnData = @"";
                    }
                    
                    [currentRow setObject:columnData forKey:columnName];
                }
                
                [alldata addObject:[currentRow retain]];
            }
        }
        sqlite3_finalize(statement);
    }
    if(sqlite3_close(databaseObj) == SQLITE_OK){
        
    }else{
        NSAssert1(0, @"Error: failed to close database on memwarning with message '%s'.", sqlite3_errmsg(databaseObj));
    }
    return [alldata retain];
    
}

#pragma mark - Get Record Count

-(int)getCount:(NSString *)query
{
    int m_count=0;
    sqlite3_stmt *statement = nil ;
    NSString *path = [self GetDatabasePath:DataBaseName] ;
    
    if(sqlite3_open([path UTF8String],&databaseObj) == SQLITE_OK )
    {
        if((sqlite3_prepare_v2(databaseObj,[query UTF8String],-1, &statement, NULL)) == SQLITE_OK)
        {
            if(sqlite3_step(statement) == SQLITE_ROW)
            {
                m_count= sqlite3_column_int(statement,0);
            }
        }
        sqlite3_finalize(statement);
    }
    if(sqlite3_close(databaseObj) == SQLITE_OK){
        
    }else{
        NSAssert1(0, @"Error: failed to close database on memwarning with message '%s'.", sqlite3_errmsg(databaseObj));
    }
    return m_count;
}

#pragma mark - Check For Record Present

-(BOOL)CheckForRecord:(NSString *)query
{
    sqlite3_stmt *statement = nil;
    NSString *path = [self GetDatabasePath:DataBaseName];
    int isRecordPresent = 0;
    
    if(sqlite3_open([path UTF8String],&databaseObj) == SQLITE_OK )
    {
        if((sqlite3_prepare_v2(databaseObj, [query UTF8String], -1, &statement, NULL)) == SQLITE_OK)
        {
            if(sqlite3_step(statement) == SQLITE_ROW)
            {
                isRecordPresent = 1;
            }
            else {
                isRecordPresent = 0;
            }
        }
    }
    sqlite3_finalize(statement);
    if(sqlite3_close(databaseObj) == SQLITE_OK){
        
    }else{
        NSAssert1(0, @"Error: failed to close database on memwarning with message '%s'.", sqlite3_errmsg(databaseObj));
    }
    return isRecordPresent;
}

#pragma mark - Insert

- (void)Insert:(NSString *)query
{
    sqlite3_stmt *statement=nil;
    NSString *path = [self GetDatabasePath:DataBaseName];
    
    if(sqlite3_open([path UTF8String],&databaseObj) == SQLITE_OK)
    {
        if((sqlite3_prepare_v2(databaseObj, [query UTF8String], -1, &statement,NULL)) == SQLITE_OK)
        {
            sqlite3_step(statement);
        }
    }
    sqlite3_finalize(statement);
    if(sqlite3_close(databaseObj) == SQLITE_OK){
        
    }else{
        NSAssert1(0, @"Error: failed to close database on memwarning with message '%s'.", sqlite3_errmsg(databaseObj));
    }
}

#pragma mark - DeleteRecord

-(void)Delete:(NSString *)query
{
    sqlite3_stmt *statement = nil;
    NSString *path = [self GetDatabasePath:DataBaseName] ;
    if(sqlite3_open([path UTF8String],&databaseObj) == SQLITE_OK )
    {
        if((sqlite3_prepare_v2(databaseObj, [query UTF8String], -1, &statement, NULL)) == SQLITE_OK)
        {
            sqlite3_step(statement);
        }
    }
    sqlite3_finalize(statement);
    if(sqlite3_close(databaseObj) == SQLITE_OK){
        
    }else{
        NSAssert1(0, @"Error: failed to close database on memwarning with message '%s'.", sqlite3_errmsg(databaseObj));
    }
}

#pragma mark - UpdateRecord

-(void)Update:(NSString *)query
{
    sqlite3_stmt *statement=nil;
    NSString *path = [self GetDatabasePath:DataBaseName] ;
    
    if(sqlite3_open([path UTF8String],&databaseObj) == SQLITE_OK)
    {
        if(sqlite3_prepare_v2(databaseObj, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
        }
        sqlite3_finalize(statement);
    }
    if(sqlite3_close(databaseObj) == SQLITE_OK){
        
    }else{
        NSAssert1(0, @"Error: failed to close database on memwarning with message '%s'.", sqlite3_errmsg(databaseObj));
    }
}

#pragma mark - Bulk Insert

-(void)updateInBulk:(NSArray *)aBulkQueryArray
{
    sqlite3 *db;
    NSString *aDatabasePath = [self GetDatabasePath:DataBaseName];
    
    //Establish connection to db
    if (sqlite3_open([aDatabasePath UTF8String], &db) == SQLITE_OK)
    {
        sqlite3_stmt *compiledStatement = nil;
        
        sqlite3_exec(db, "BEGIN EXCLUSIVE TRANSACTION", 0, 0, 0);
        for (int i=0;i<[aBulkQueryArray count];i++)
        {
            NSString *query2 = [aBulkQueryArray objectAtIndex:i];
            
            
            if(sqlite3_prepare(db, [query2 UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK)
            {
                
            }
            if (sqlite3_step(compiledStatement) != SQLITE_DONE) NSLog(@"DB not updated. Error: %s",sqlite3_errmsg(db));
            if (sqlite3_finalize(compiledStatement) != SQLITE_OK) NSLog(@"SQL Error: %s",sqlite3_errmsg(db));
        }
        if (sqlite3_exec(db, "COMMIT TRANSACTION", 0, 0, 0) != SQLITE_OK) NSLog(@"SQL Error: %s",sqlite3_errmsg(db));
        sqlite3_close(db);
    }
    else
        NSLog(@"sql-error: %s", sqlite3_errmsg(db));
}

#pragma mark - Alter Table

-(void)alterTable:(NSString *)query
{
    sqlite3_stmt *statement = nil ;
    sqlite3 *db;

    NSString *aDatabasePath = [self GetDatabasePath:DataBaseName];
    
    if(sqlite3_open([aDatabasePath UTF8String],&db) == SQLITE_OK )
    {
        if((sqlite3_prepare_v2(db,[query UTF8String],-1, &statement, NULL)) == SQLITE_OK)
        {
            sqlite3_step(statement);
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(db);
}

@end