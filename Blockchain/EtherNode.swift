//
/* Copyright(C) 2017 Teambrella, Inc.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License(version 3) as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see<http://www.gnu.org/licenses/>.
 */

import Foundation

class EtherNode {
    struct Constant {
        static let testAuthorities: [String] = ["https://ropsten.etherscan.io"]
        static let mainAuthorities: [String] = ["http://api.etherscan.io"]
    }
    
    private var mEthereumAPIs: [EtherAPI] = []
    private var mIsTestNet: Bool
    
    init(isTestNet: Bool) {
        mIsTestNet = isTestNet
        
        /*
         HttpLoggingInterceptor interceptor = new HttpLoggingInterceptor();
         interceptor.setLevel(HttpLoggingInterceptor.Level.BODY);
         OkHttpClient client = new OkHttpClient.Builder().addInterceptor(interceptor).build();
         
         Gson gson = new GsonBuilder()
         .setLenient()
         .create();
         
         String authorities[] = mIsTestNet ? TEST_AUTHORITIES : MAIN_AUTHORITIES;
         for (String authority : authorities) {
         mEtherAPIs.add(new Retrofit.Builder()
         .baseUrl(authority)
         .addConverterFactory(ScalarsConverterFactory.create())
         .addConverterFactory(GsonConverterFactory.create(gson))
         .client(client)
         .build().create(EtherAPI.class));
         }
         */
    }
    
    func pushTx(hex: String) -> String {
        return ""
        /*
         JsonObject result = null;
         for (EtherAPI api : mEtherAPIs) {
         try {
         Response<JsonObject> response = api.pushTx(hex).execute();
         if (response.isSuccessful()) {
         result = response.body();
         //        {
         //            "jsonrpc": "2.0",
         //                "error": {
         //            "code": -32010,
         //                    "message": "Transaction nonce is too low. Try incrementing the nonce.",
         //                    "data": null
         //        },
         //            "id": 1
         //        {
         //              "jsonrpc": "2.0",
         //              "result": "0x918a3313e6c1c5a0068b5234951c916aa64a8074fdbce0fecbb5c9797f7332f6",
         //              "id": 1
         //          }
         
         JsonElement r = result.get("result");
         if (r != null)
         return r.getAsString();
         else
         Log.e(LOG_TAG, "Could not publish eth multisig creation tx. The answer was: " + result.toString());
         
         }
         } catch (IOException e) {
         Log.e(LOG_TAG, e.toString());
         }
         }
         return null;
         */
    }
    
    //    func checkTx(creationTx: String) -> Future<
    //    func checkTx(creationTx: String, success: () -> Void, failure: (Error) -> Void) {
    //
    //    }
}

