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

/*
class EthereumNode {
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
    
    func checkTx(creationTx: String) -> Future<
    func checkTx(creationTx: String, success: () -> Void, failure: (Error) -> Void) {
        
    }
}
*/
